using System;
using BuildTools.Git.Raw;
using System.IO;
using System;

namespace BuildTools
{
	public static class GitTools
	{
		static this()
		{
			git_libgit2_init();
		}

		static ~this()
		{
			git_libgit2_shutdown();
		}

		public static GitErrorCode Clone(StringView url, StringView path)
		{
			void* repo = ?;
			return git_clone(&repo, scope String(url).CStr(), scope String(path).CStr(), null);
		}

		public static GitError GetLastError()
		{
			let raw = giterr_last();
			return .() { Message = .(raw.Message), ErrorClass = (.)raw.Klass };
		}

		public static Result<void, GitErrorCode> UpdateSubmodules(StringView path = ".", bool recursive = false)
		{
			void* repo = null;
			git_repository_open(&repo, scope String(path).CStr());
			return UpdateSubmodules(repo, path, recursive);
		}

		private static Result<void, GitErrorCode> UpdateSubmodules(void* repo, StringView path, bool recursive)
		{
			var payload = Payload() {
				recursive = recursive,
				path = path
			};

			let result = git_submodule_foreach(repo, (submodule, name, _payload) =>
				{
					let payload = (Payload*)_payload;

					char8* url = git_submodule_url(submodule);
					if (url == null)
						return (.)GitErrorCode.GIT_ERROR;

					void* subrepo = null;
					let submodule_path = StringView(git_submodule_path(submodule));
					let path = Path.InternalCombine(.. scope .(), payload.path, submodule_path);

					var clone_options = git_clone_options();
					clone_options.checkout_opts.checkout_strategy = .GIT_CHECKOUT_NONE;
					let clone_result = git_clone(&subrepo, url, path.CStr(), &clone_options);
					if (clone_result != .GIT_OK)
					{
						if (clone_result != .GIT_EEXISTS)
							return (.)clone_result;

						let open_result = git_repository_open(&subrepo, path.CStr());
						if (open_result != .GIT_OK)
							return (.)open_result;
					}

					let set_head_result = git_repository_set_head_detached(subrepo, git_submodule_index_id(submodule));
					if (set_head_result != .GIT_OK)
						return (.)set_head_result;

					let checkout_result = git_checkout_head(subrepo, &git_checkout_options());
					if (checkout_result != .GIT_OK)
						return (.)checkout_result;

					if (payload.recursive)
					{
						if (UpdateSubmodules(subrepo, path, true) case .Err(let err))
							return (.)err;
					}

					return (.)GitErrorCode.GIT_OK;
				}, &payload);

			if (result == .GIT_OK)
				return .Ok;

			return .Err(result);
		}

		struct Payload
		{
			public bool recursive;
			public StringView path;
		}
	}
}
    