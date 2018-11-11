import vibe.vibe;
import vibe.core.file;
import vibe.core.log;
import vibe.core.path;
import vibe.http.router;
import vibe.http.server;
import std.path: buildPath;
import std.exception;


void uploadFile(scope HTTPServerRequest req,scope HTTPServerResponse res)
{
  auto pf = "file" in req.files;
  logInfo(req.requestURI);
  enforce(pf !is null,"no file uploaded !");
// https://dlang.org/library/std/file/mkdir_recurse.html
/*  auto nested = NativePath("./public/uploads"); 
  if (!nested.exists)
  {
    logError("[./public/uploads] repository does not exist and can not be create ");
  }*/
  try moveFile(pf.tempPath,NativePath("./public/uploads")~pf.filename);
  catch (Exception e)
       {
        logWarn("Failed to move file to destination folder: %s ",e.msg);
        logInfo("Perming a copy+delete instead..");
        copyFile(pf.tempPath,NativePath("./public/uploads")~pf.filename);
       }
  //res.writeBody("file uploaded","text/plain");
  res.redirect("/");
}

void main()
{
  auto router = new URLRouter;
  router.get("/",staticTemplate!"upload_form.dt");
  router.post("/upload/*",&uploadFile);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings,router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}
