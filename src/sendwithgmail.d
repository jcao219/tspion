module sendwithgmail;

import etc.c.curl;
import std.stdio;
import etc.curl;
import std.string;
import std.c.string : memcpy;

struct PutData
{
    const(char)* data;
    size_t len;
}

extern(C) size_t read_callback(void* ptr, size_t size, size_t nmemb, void* userp)
{
    auto pdata = cast(PutData*)userp;
    if((size*nmemb) < 1) return 0;
    size_t curl_size = nmemb * size;
    size_t to_copy = (pdata.len < curl_size) ? pdata.len : curl_size;
    memcpy(ptr, pdata.data, to_copy);
    pdata.len -= to_copy;
    pdata.data += to_copy;
    return to_copy;
}

string formatEmailData(string rawData, string from, string subject)
{
     return "From: " ~ from ~ "\nSubject: " ~ subject ~ "\n" ~ rawData;
}

void sendStringWithGmail(string username, string password, string recipient, string data, Curl curl = null)
{
    sendStringWithGmail(username, password, [recipient], data, curl);
}

void sendStringWithGmail(string username, string password, string[] recipients, string data, Curl curl = null)
{
    sendWithGmail(username, password, recipients, cast(void*)&(PutData(toStringz(data),  data.length)), data.length, true, curl);
}

version(!Windows)  //Segfaults when data is sent to SMTP server on Windows, but not on Linux... strange
{
void sendWithGmail(string username, string password, string recipient, string filename, Curl curl = null)
{
    sendWithGmail(username, password, [recipient], filename, curl);
}

void sendWithGmail(string username, string password, string[] recipients, string filename, Curl curl = null)
{
    auto fd = File(filename, "rb");
    sendWithGmail(username, password, recipients, &fd, curl);
    scope(exit) fd.close();
}

void sendWithGmail(string username, string password, string[] recipients, File* fdp, Curl curl = null)
{
    sendWithGmail(username, password, recipients, cast(void*)(*fdp).getFP(), (*fdp).size, false, curl);
}
}

void sendWithGmail(string username, string password, string[] recipients, void* fp, ulong size, bool notFile, Curl curl = null)
{
    if(!curl) curl = new Curl();
    
    curl.set(CurlOption.infile, fp);
    curl.set(CurlOption.infilesize_large, size);
    curl.set(CurlOption.timeout, 180);
    if(notFile) curl.set(CurlOption.readfunction, cast(void*)&read_callback);
    curl.set(CurlOption.use_ssl, CurlUseSSL.all);
    curl.set(CurlOption.ssl_verifypeer, 0);
    curl.set(CurlOption.ssl_verifyhost, 2);
    curl.set(CurlOption.url, "smtps://smtp.gmail.com");
    curl.set(CurlOption.mail_from, "<"~username~">");
   
    curl_slist* rcptl = null;
    foreach(recipient; recipients)
    	rcptl = curl_slist_append(rcptl, cast(char*)toStringz("<"~recipient~">"));
    curl.set(CurlOption.mail_rcpt, cast(void*)rcptl);

    curl.set(CurlOption.userpwd, username~":"~password);

    curl.perform();
}