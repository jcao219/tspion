module sendwithgmail;

import etc.c.curl;
import std.stdio;
import etc.curl;
import std.string;

void sendWithGmail(string username, string password, string recipient, string filename)
{
    sendWithGmail(username, password, [recipient], filename);
}

void sendWithGmail(string username, string password, string[] recipients, string filename)
{
    Curl curl = new Curl();
    auto fd = File(filename, "rb");
    scope(exit) fd.close();
    curl.set(CurlOption.infile, cast(void*)fd.getFP);
    curl.set(CurlOption.infilesize_large, fd.size);
    curl.set(CurlOption.timeout, 180);
    curl.set(CurlOption.use_ssl, CurlUseSSL.all);
    curl.set(CurlOption.url, "smtps://smtp.gmail.com");
    curl.set(CurlOption.mail_from, "<"~username~">");
   
    curl_slist* rcptl = null;
    foreach(recipient; recipients)
    	rcptl = curl_slist_append(rcptl, cast(char*)toStringz("<"~recipient~">"));
    curl.set(CurlOption.mail_rcpt, cast(void*)rcptl);

    curl.set(CurlOption.userpwd, username~":"~password);

    curl.perform();
}
