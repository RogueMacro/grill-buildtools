using System;

namespace BuildTools.Git.Raw
{
	public static
	{
		typealias Oid = uint8[20];

		[CLink]
		public static extern GitErrorCode git_libgit2_init();

		[CLink]
		public static extern GitErrorCode git_libgit2_shutdown();

		[CLink]
		public static extern GitErrorCode git_clone(void** git_repository, char8* url, char8* local_path, git_clone_options* options);

		[CLink]
		public static extern GitErrorCode git_submodule_update(void* submodule, int32 init, void* options);

		[CLink]
		public static extern GitErrorCode git_submodule_clone(void** out_repo, void* submodule, void* options);

		[CLink]
		public static extern GitErrorCode git_submodule_foreach(void* repo, function int32(void* submodule, char8* name, void* payload) callback, void* payload);

		[CLink]
		public static extern GitErrorCode git_submodule_init(void* submodule, int32 overwrite);

		[CLink]
		public static extern GitErrorCode git_repository_open(void** out_repo, char8* path);

		[CLink]
		public static extern GitErrorCode git_repository_head(void** out_ref, void* repo);

		[CLink]
		public static extern GitErrorCode git_reference_lookup(void** out_ref, void* repo, char8* name);

		[CLink]
		public static extern GitErrorCode git_revwalk_new(void** out_ref, void* repo);

		[CLink]
		public static extern GitErrorCode git_revwalk_push_ref(void* revwalk, char8* refname);

		[CLink]
		public static extern GitErrorCode git_revwalk_next(Oid* out_oid, void* revwalk);

		[CLink]
		public static extern GitErrorCode git_reference_set_target(void** out_ref, void* reference, Oid* id, char8* log_message);

		[CLink]
		public static extern GitErrorCode git_repository_set_head_detached(void* repo, Oid* committish);

		[CLink]
		public static extern GitErrorCode git_repository_set_head(void* repo, char8* refname);

		[CLink]
		public static extern GitErrorCode git_checkout_head(void* repo, void* opts);

		[CLink]
		public static extern GitErrorCode git_checkout_tree(void* repo, void* object, void* opts);

		[CLink]
		public static extern GitErrorCode git_repository_free(void* repo);

		[CLink]
		public static extern GitErrorCode git_revwalk_free(void* revwalk);

		[CLink]
		public static extern GitErrorCode git_checkout_options_init(void* opts, uint32 version);

		[CLink]
		public static extern GitErrorCode git_tag_foreach(void* repo, function int32(char8* name, void* oid, void* payload) callback, void* payload);

		[CLink]
		public static extern RawGitError* giterr_last();

		[CRepr]
		public struct RawGitError
		{
			public char8* Message;
			public GitErrorClass Klass;
		}

		[CRepr] public enum git_clone_local_t
		{
			/**
			 * Auto-detect (default), libgit2 will bypass the git-aware
			 * transport for local paths, but use a normal fetch for
			 * `file://` urls.
			 */
			GIT_CLONE_LOCAL_AUTO,
			/**
			 * Bypass the git-aware transport even for a `file://` url.
			 */
			GIT_CLONE_LOCAL,
			/**
			 * Do no bypass the git-aware transport
			 */
			GIT_CLONE_NO_LOCAL,
			/**
			 * Bypass the git-aware transport, but do not try to use
			 * hardlinks.
			 */
			GIT_CLONE_LOCAL_NO_LINKS
		}

		typealias git_repository_create_cb = function GitErrorCode(
			void** out_repo,
			char8* path,
			int32 bare,
			void* payload);

		public typealias git_remote_create_cb = function GitErrorCode(
			void** out_remote,
			void* repo,
			char8* name,
			char8* url,
			void* payload);

		[CRepr]
		public struct git_clone_options
		{
			uint32 version = 1;

			/**
			 * These options are passed to the checkout step. To disable
			 * checkout, set the `checkout_strategy` to
			 * `GIT_CHECKOUT_NONE`.
			 */
			public git_checkout_options checkout_opts = .();

			/**
			 * Options which control the fetch, including callbacks.
			 *
			 * The callbacks are used for reporting fetch progress, and for acquiring
			 * credentials in the event they are needed.
			 */
			public git_fetch_options fetch_opts = .();

			/**
			 * Set to zero (false) to create a standard repo, or non-zero
			 * for a bare repo
			 */
			public int32 bare;

			/**
			 * Whether to use a fetch or copy the object database.
			 */
			public git_clone_local_t local;

			/**
			 * The name of the branch to checkout. NULL means use the
			 * remote's default branch.
			 */
			public char8* checkout_branch;

			/**
			 * A callback used to create the new repository into which to
			 * clone. If NULL, the 'bare' field will be used to determine
			 * whether to create a bare repository.
			 */
			public git_repository_create_cb repository_cb;

			/**
			 * An opaque payload to pass to the git_repository creation callback.
			 * This parameter is ignored unless repository_cb is non-NULL.
			 */
			public void* repository_cb_payload;

			/**
			 * A callback used to create the git_remote, prior to its being
			 * used to perform the clone operation. See the documentation for
			 * git_remote_create_cb for details. This parameter may be NULL,
			 * indicating that git_clone should provide default behavior.
			 */
			public git_remote_create_cb remote_cb;

			/**
			 * An opaque payload to pass to the git_remote creation callback.
			 * This parameter is ignored unless remote_cb is non-NULL.
			 */
			public void* remote_cb_payload;
		}

		[CRepr]
		public struct git_remote_callbacks
		{
			uint32 version = 1; /**< The version */

			/**
			 * Textual progress from the remote. Text send over the
			 * progress side-band will be passed to this function (this is
			 * the 'counting objects' output).
			 */
			void* sideband_progress;

			/**
			 * Completion is called when different parts of the download
			 * process are done (currently unused).
			 */
			void* completion;

			/**
			 * This will be called if the remote host requires
			 * authentication in order to connect to it.
			 *
			 * Returning GIT_PASSTHROUGH will make libgit2 behave as
			 * though this field isn't set.
			 */
			git_credential_acquire_cb credentials;

			/**
			 * If cert verification fails, this will be called to let the
			 * user make the final decision of whether to allow the
			 * connection to proceed. Returns 0 to allow the connection
			 * or a negative value to indicate an error.
			 */
			git_transport_certificate_check_cb certificate_check;

			/**
			 * During the download of new data, this will be regularly
			 * called with the current count of progress done by the
			 * indexer.
			 */
			void* transfer_progress;

			/**
			 * Each time a reference is updated locally, this function
			 * will be called with information about it.
			 */
			void* update_tips;

			/**
			 * Function to call with progress information during pack
			 * building. Be aware that this is called inline with pack
			 * building operations, so performance may be affected.
			 */
			void* pack_progress;

			/**
			 * Function to call with progress information during the
			 * upload portion of a push. Be aware that this is called
			 * inline with pack building operations, so performance may be
			 * affected.
			 */
			void* push_transfer_progress;

			/**
			 * See documentation of git_push_update_reference_cb
			 */
			void* push_update_reference;

			/**
			 * Called once between the negotiation step and the upload. It
			 * provides information about what updates will be performed.
			 */
			void* push_negotiation;

			/**
			 * Create the transport to use for this operation. Leave NULL
			 * to auto-detect.
			 */
			void* transport;

			/**
			 * Callback when the remote is ready to connect.
			 */
			void* remote_ready;

			/**
			 * This will be passed to each of the callbacks in this struct
			 * as the last parameter.
			 */
			void* payload;

			/**
			 * Resolve URL before connecting to remote.
			 * The returned URL will be used to connect to the remote instead.
			 *
			 * This callback is deprecated; users should use
			 * git_remote_ready_cb and configure the instance URL instead.
			 */
			void* resolve_url;
		}

		[CRepr] public enum git_fetch_prune_t
		{
			/**
			 * Use the setting from the configuration
			 */
			GIT_FETCH_PRUNE_UNSPECIFIED,
			/**
			 * Force pruning on
			 */
			GIT_FETCH_PRUNE,
			/**
			 * Force pruning off
			 */
			GIT_FETCH_NO_PRUNE
		}

		[CRepr] public enum git_remote_autotag_option_t
		{
			/**
			 * Use the setting from the configuration.
			 */
			GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED = 0,
			/**
			 * Ask the server for tags pointing to objects we're already
			 * downloading.
			 */
			GIT_REMOTE_DOWNLOAD_TAGS_AUTO,
			/**
			 * Don't ask for any tags beyond the refspecs.
			 */
			GIT_REMOTE_DOWNLOAD_TAGS_NONE,
			/**
			 * Ask for the all the tags.
			 */
			GIT_REMOTE_DOWNLOAD_TAGS_ALL
		}

		[CRepr] public enum git_proxy_t
		{
			/**
			 * Do not attempt to connect through a proxy
			 *
			 * If built against libcurl, it itself may attempt to connect
			 * to a proxy if the environment variables specify it.
			 */
			GIT_PROXY_NONE,
			/**
			 * Try to auto-detect the proxy from the git configuration.
			 */
			GIT_PROXY_AUTO,
			/**
			 * Connect via the URL given in the options
			 */
			GIT_PROXY_SPECIFIED
		}

		[CRepr]
		public struct git_credential;

		typealias git_credential_acquire_cb = function GitErrorCode(
			git_credential** out_credentials,
			char8* url,
			char8* username_from_url,
			uint32 allowed_types,
			void* payload);

		typealias git_transport_certificate_check_cb = function GitErrorCode(void* cert, int32 valid, char8* host, void* payload);

		[CRepr]
		public struct git_proxy_options
		{
			uint32 version = 1;

			/**
			 * The type of proxy to use, by URL, auto-detect.
			 */
			git_proxy_t type;

			/**
			 * The URL of the proxy.
			 */
			char8* url;

			/**
			 * This will be called if the remote host requires
			 * authentication in order to connect to it.
			 *
			 * Returning GIT_PASSTHROUGH will make libgit2 behave as
			 * though this field isn't set.
			 */
			git_credential_acquire_cb credentials;

			/**
			 * If cert verification fails, this will be called to let the
			 * user make the final decision of whether to allow the
			 * connection to proceed. Returns 0 to allow the connection
			 * or a negative value to indicate an error.
			 */
			git_transport_certificate_check_cb certificate_check;

			/**
			 * Payload to be provided to the credentials and certificate
			 * check callbacks.
			 */
			void* payload;
		}

		[CRepr] public enum git_remote_redirect_t
		{
			/**
			 * Do not follow any off-site redirects at any stage of
			 * the fetch or push.
			 */
			GIT_REMOTE_REDIRECT_NONE = (1 << 0),

			/**
			 * Allow off-site redirects only upon the initial request.
			 * This is the default.
			 */
			GIT_REMOTE_REDIRECT_INITIAL = (1 << 1),

			/**
			 * Allow redirects at any stage in the fetch or push.
			 */
			GIT_REMOTE_REDIRECT_ALL = (1 << 2)
		}

		[CRepr]
		public struct git_fetch_options
		{
			int32 version = 1;

			/**
			 * Callbacks to use for this fetch operation
			 */
			git_remote_callbacks callbacks = .();

			/**
			 * Whether to perform a prune after the fetch
			 */
			git_fetch_prune_t prune;

			/**
			 * Whether to write the results to FETCH_HEAD. Defaults to
			 * on. Leave this default in order to behave like git.
			 */
			int32 update_fetchhead;

			/**
			 * Determines how to behave regarding tags on the remote, such
			 * as auto-downloading tags for objects we're downloading or
			 * downloading all of them.
			 *
			 * The default is to auto-follow tags.
			 */
			git_remote_autotag_option_t download_tags;

			/**
			 * Proxy options to use, by default no proxy is used.
			 */
			git_proxy_options proxy_opts = .();

			/**
			 * Whether to allow off-site redirects.  If this is not
			 * specified, the `http.followRedirects` configuration setting
			 * will be consulted.
			 */
			git_remote_redirect_t follow_redirects;

			/**
			 * Extra headers for this fetch operation
			 */
			git_strarray custom_headers;
		}

		[CRepr]
		public struct GitError
		{
			public StringView Message;
			public GitErrorClass ErrorClass;
		}

		[CRepr, Reflect(.StaticFields)]
		public enum GitErrorCode
		{
			GIT_OK = 0, /**< No error */

			GIT_ERROR = -1, /**< Generic error */
			GIT_ENOTFOUND = -3, /**< Requested object could not be found */
			GIT_EEXISTS = -4, /**< Object exists preventing operation */
			GIT_EAMBIGUOUS = -5, /**< More than one object matches */
			GIT_EBUFS = -6, /**< Output buffer too short to hold data */

			/**
			 * GIT_EUSER is a special error that is never generated by libgit2
			 * code.  You can return it from a callback (e.g to stop an iteration)
			 * to know that it was generated by the callback and not by libgit2.
			 */
			GIT_EUSER = -7,

			GIT_EBAREREPO = -8, /**< Operation not allowed on bare repository */
			GIT_EUNBORNBRANCH = -9, /**< HEAD refers to branch with no commits */
			GIT_EUNMERGED = -10, /**< Merge in progress prevented operation */
			GIT_ENONFASTFORWARD = -11, /**< Reference was not fast-forwardable */
			GIT_EINVALIDSPEC = -12, /**< Name/ref spec was not in a valid format */
			GIT_ECONFLICT = -13, /**< Checkout conflicts prevented operation */
			GIT_ELOCKED = -14, /**< Lock file prevented operation */
			GIT_EMODIFIED = -15, /**< Reference value does not match expected */
			GIT_EAUTH = -16, /**< Authentication error */
			GIT_ECERTIFICATE = -17, /**< Server certificate is invalid */
			GIT_EAPPLIED = -18, /**< Patch/merge has already been applied */
			GIT_EPEEL = -19, /**< The requested peel operation is not possible */
			GIT_EEOF = -20, /**< Unexpected EOF */
			GIT_EINVALID = -21, /**< Invalid operation or input */
			GIT_EUNCOMMITTED = -22, /**< Uncommitted changes in index prevented operation */
			GIT_EDIRECTORY = -23, /**< The operation is not valid for a directory */
			GIT_EMERGECONFLICT = -24, /**< A merge conflict exists and cannot continue */

			GIT_PASSTHROUGH = -30, /**< A user-configured callback refused to act */
			GIT_ITEROVER = -31, /**< Signals end of iteration with iterator */
			GIT_RETRY = -32, /**< Internal only */
			GIT_EMISMATCH = -33, /**< Hashsum mismatch in object */
			GIT_EINDEXDIRTY = -34, /**< Unsaved changes in the index would be overwritten */
			GIT_EAPPLYFAIL = -35, /**< Patch application failed */
			GIT_EOWNER = -36 /**< The object is not owned by the current user */
		}

		[CRepr, Reflect(.StaticFields)]
		public enum GitErrorClass {
			GIT_ERROR_NONE = 0,
			GIT_ERROR_NOMEMORY,
			GIT_ERROR_OS,
			GIT_ERROR_INVALID,
			GIT_ERROR_REFERENCE,
			GIT_ERROR_ZLIB,
			GIT_ERROR_REPOSITORY,
			GIT_ERROR_CONFIG,
			GIT_ERROR_REGEX,
			GIT_ERROR_ODB,
			GIT_ERROR_INDEX,
			GIT_ERROR_OBJECT,
			GIT_ERROR_NET,
			GIT_ERROR_TAG,
			GIT_ERROR_TREE,
			GIT_ERROR_INDEXER,
			GIT_ERROR_SSL,
			GIT_ERROR_SUBMODULE,
			GIT_ERROR_THREAD,
			GIT_ERROR_STASH,
			GIT_ERROR_CHECKOUT,
			GIT_ERROR_FETCHHEAD,
			GIT_ERROR_MERGE,
			GIT_ERROR_SSH,
			GIT_ERROR_FILTER,
			GIT_ERROR_REVERT,
			GIT_ERROR_CALLBACK,
			GIT_ERROR_CHERRYPICK,
			GIT_ERROR_DESCRIBE,
			GIT_ERROR_REBASE,
			GIT_ERROR_FILESYSTEM,
			GIT_ERROR_PATCH,
			GIT_ERROR_WORKTREE,
			GIT_ERROR_SHA1,
			GIT_ERROR_HTTP,
			GIT_ERROR_INTERNAL
		} 

		[CRepr] public enum git_checkout_strategy_t
		{
			GIT_CHECKOUT_NONE = 0, /**< default is a dry run, no actual updates */

			/**
			 * Allow safe updates that cannot overwrite uncommitted data.
			 * If the uncommitted changes don't conflict with the checked out files,
			 * the checkout will still proceed, leaving the changes intact.
			 *
			 * Mutually exclusive with GIT_CHECKOUT_FORCE.
			 * GIT_CHECKOUT_FORCE takes precedence over GIT_CHECKOUT_SAFE.
			 */
			GIT_CHECKOUT_SAFE = (1u << 0),

			/**
			 * Allow all updates to force working directory to look like index.
			 *
			 * Mutually exclusive with GIT_CHECKOUT_SAFE.
			 * GIT_CHECKOUT_FORCE takes precedence over GIT_CHECKOUT_SAFE.
			 */
			GIT_CHECKOUT_FORCE = (1u << 1),


			/** Allow checkout to recreate missing files */
			GIT_CHECKOUT_RECREATE_MISSING = (1u << 2),

			/** Allow checkout to make safe updates even if conflicts are found */
			GIT_CHECKOUT_ALLOW_CONFLICTS = (1u << 4),

			/** Remove untracked files not in index (that are not ignored) */
			GIT_CHECKOUT_REMOVE_UNTRACKED = (1u << 5),

			/** Remove ignored files not in index */
			GIT_CHECKOUT_REMOVE_IGNORED = (1u << 6),

			/** Only update existing files, don't create new ones */
			GIT_CHECKOUT_UPDATE_ONLY = (1u << 7),

			/**
			 * Normally checkout updates index entries as it goes; this stops that.
			 * Implies `GIT_CHECKOUT_DONT_WRITE_INDEX`.
			 */
			GIT_CHECKOUT_DONT_UPDATE_INDEX = (1u << 8),

			/** Don't refresh index/config/etc before doing checkout */
			GIT_CHECKOUT_NO_REFRESH = (1u << 9),

			/** Allow checkout to skip unmerged files */
			GIT_CHECKOUT_SKIP_UNMERGED = (1u << 10),
			/** For unmerged files, checkout stage 2 from index */
			GIT_CHECKOUT_USE_OURS = (1u << 11),
			/** For unmerged files, checkout stage 3 from index */
			GIT_CHECKOUT_USE_THEIRS = (1u << 12),

			/** Treat pathspec as simple list of exact match file paths */
			GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH = (1u << 13),

			/** Ignore directories in use, they will be left empty */
			GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES = (1u << 18),

			/** Don't overwrite ignored files that exist in the checkout target */
			GIT_CHECKOUT_DONT_OVERWRITE_IGNORED = (1u << 19),

			/** Write normal merge files for conflicts */
			GIT_CHECKOUT_CONFLICT_STYLE_MERGE = (1u << 20),

			/** Include common ancestor data in diff3 format files for conflicts */
			GIT_CHECKOUT_CONFLICT_STYLE_DIFF3 = (1u << 21),

			/** Don't overwrite existing files or folders */
			GIT_CHECKOUT_DONT_REMOVE_EXISTING = (1u << 22),

			/** Normally checkout writes the index upon completion; this prevents that. */
			GIT_CHECKOUT_DONT_WRITE_INDEX = (1u << 23),

			/**
			 * Show what would be done by a checkout.  Stop after sending
			 * notifications; don't update the working directory or index.
			 */
			GIT_CHECKOUT_DRY_RUN = (1u << 24),

			/** Include common ancestor data in zdiff3 format for conflicts */
			GIT_CHECKOUT_CONFLICT_STYLE_ZDIFF3 = (1u << 25),

			/**
			 * THE FOLLOWING OPTIONS ARE NOT YET IMPLEMENTED
			 */

			/** Recursively checkout submodules with same options (NOT IMPLEMENTED) */
			GIT_CHECKOUT_UPDATE_SUBMODULES = (1u << 16),
			/** Recursively checkout submodules if HEAD moved in super repo (NOT IMPLEMENTED) */
			GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED = (1u << 17)

		}

		[CRepr]
		public struct git_checkout_options
		{
			uint32 version = 1; /**< The version */

			public git_checkout_strategy_t checkout_strategy = .GIT_CHECKOUT_SAFE; /**< default will be a safe checkout */

			public int32 disable_filters; /**< don't apply filters like CRLF conversion */
			public uint32 dir_mode; /**< default is 0755 */
			public uint32 file_mode; /**< default is 0644 or 0755 as dictated by blob */
			public int32 file_open_flags; /**< default is O_CREAT | O_TRUNC | O_WRONLY */

			public uint32 notify_flags; /**< see `git_checkout_notify_t` above */

			/**
			 * Optional callback to get notifications on specific file states.
			 * @see git_checkout_notify_t
			 */
			public void* notify_cb;

			/** Payload passed to notify_cb */
			public void* notify_payload;

			/** Optional callback to notify the consumer of checkout progress. */
			public void* progress_cb;

			/** Payload passed to progress_cb */
			public void* progress_payload;

			/**
			 * A list of wildmatch patterns or paths.
			 *
			 * By default, all paths are processed. If you pass an array of wildmatch
			 * patterns, those will be used to filter which paths should be taken into
			 * account.
			 *
			 * Use GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH to treat as a simple list.
			 */
			public git_strarray paths;

			/**
			 * The expected content of the working directory; defaults to HEAD.
			 *
			 * If the working directory does not match this baseline information,
			 * that will produce a checkout conflict.
			 */
			public void* baseline;

			/**
			 * Like `baseline` above, though expressed as an index.  This
			 * option overrides `baseline`.
			 */
			public void* baseline_index;

			public char8* target_directory; /**< alternative checkout path to workdir */

			public char8* ancestor_label; /**< the name of the common ancestor side of conflicts */
			public char8* our_label; /**< the name of the "our" side of conflicts */
			public char8* their_label; /**< the name of the "their" side of conflicts */

			/** Optional callback to notify the consumer of performance data. */
			public void* perfdata_cb;

			/** Payload passed to perfdata_cb */
			public void* perfdata_payload;
		}

		[CRepr]
		public struct git_strarray
		{
			char8** strings;
			uint32 count;
		}



		[CLink]
		public static extern Oid* git_submodule_index_id(void* submodule);

		[CLink]
		public static extern GitErrorCode submodule_repo_init(void** out_repo, void* parent_repo, char8* path, char8* url, bool use_gitlink);

		[CLink]
		public static extern char8* git_submodule_url(void* submodule);

		[CLink]
		public static extern char8* git_submodule_path(void* submodule);

		[CLink]
		public static extern GitErrorCode git_repository_init(void** out_repo, char8* path, uint32 is_bare);

	}
}