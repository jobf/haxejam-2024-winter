using DateTools;

#if sys
function main()
{
	var host_remote = sys.io.File.getContent("secrets/remote_host");
	var path_remote = sys.io.File.getContent("secrets/remote_path");

	if (host_remote.length == 0 || path_remote.length == 0)
	{
		trace('Cannot deploy without secrets.');
	}

	var path_local = "dist/html5/bin/";

	// var file_name_index = "index.html";
	// var file_name_readme = "readme.md";

	// append_readme(path_local, file_name_index, file_name_readme);

	var path_version = Date.now().format("%d-%H-%M");

	var command: String = "scp";

	var args: Array<String> = ["-r", path_local, '$host_remote:$path_remote/$path_version',];

	Sys.command(command, args);
}
#end
