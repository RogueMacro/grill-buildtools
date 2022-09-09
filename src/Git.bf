using System;

namespace BuildScriptTools.Git
{
    public static class GitTools
    {
		[CLink]
		static extern int32 git_libgit2_init();

		[CLink]
		static extern int32 git_libgit2_shutdown();

		[CLink]
		static extern int32 git_clone(void** git_repository, char8* url, char8* local_path, void* options);

		[CLink]
		static extern int32 git_submodule_update(void* submodule, int32 init, void* options);

		[CLink]
		static extern int32 git_submodule_clone(void** out_repo, void* submodule, void* options);

		[CLink]
		static extern int32 git_submodule_foreach(void* repo, function int32(void*, char8*, void*) callback, void* payload);

		[CLink]
		static extern int32 git_repository_open(void** out_repo, char8* path);

		[CLink]
		static extern GitError* giterr_last();

		[CRepr]
		public struct GitError
		{
			public char8* Message;
			public int32 Klass;
		}

		static this()
		{
			git_libgit2_init();
		}

		static ~this()
		{
			git_libgit2_shutdown();
		}

        public static bool UpdateSubmodules()
		{
			void* repo = null;
			if (git_repository_open(&repo, ".") != 0)
			{
				return false;
			}
			

			return git_submodule_foreach(repo, => UpdateSubmodule, null) == 0;
		}

		static int32 UpdateSubmodule(void* submodule, char8* name, void* payload)
		{
			return git_submodule_update(submodule, 1, null);
		}

		public static GitError* GetLastError()
		{
			return giterr_last();
		}
    }
}
    