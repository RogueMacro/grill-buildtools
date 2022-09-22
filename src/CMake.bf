using System;
using System.IO;
using System.Diagnostics;

namespace BuildTools
{
	public static class CMake
	{
		public class Command
		{
			public int ExitCode { get; private set; };
			private FileStream OutputStream ~ if (_ != null) delete _;

			private void Set(int exitCode, FileStream outputStream)
			{
				ExitCode = exitCode;
				OutputStream = outputStream;
			}

			public Result<void> ReadOutput(String buffer)
			{
				if (OutputStream == null)
					return .Err;
				return scope StreamReader(OutputStream).ReadToEnd(buffer);
			}
		}

		public static bool IsAvailable
		{
			get => Run("--version") case .Ok;
		}

		public static Result<void> Run(StringView args, bool captureOutput = true)
		{
			return Run(args, scope .(), captureOutput);
		}

		public static Result<void> Run(StringView args, Command outCommand, bool captureOutput = true)
		{
			ProcessStartInfo psi = scope .();
			
			psi.UseShellExecute = false;
			psi.CreateNoWindow = captureOutput;
			psi.RedirectStandardOutput = captureOutput;
			psi.SetFileName("cmake");
			psi.SetArguments(args);
			
			SpawnedProcess process = scope .();
			if (process.Start(psi) case .Err)
				return .Err;

			FileStream fs = null;
			if (captureOutput)
			{
				fs = new .();
				process.AttachStandardOutput(fs);
			}

			outCommand.[Friend]Set(process.ExitCode, fs);
			return .Ok;
		}
	}
}