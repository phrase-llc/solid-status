function handler(event) {
  var request = event.request;
  var host = request.headers.host.value.toLowerCase();
  var baseDomain = "example.com"; // Deploy with the production base domain.
  var suffix = "." + baseDomain;

  if (!host.endsWith(suffix)) return request;

  var slug = host.slice(0, -suffix.length);
  if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(slug)) return request;

  request.uri = "/status-pages/" + slug + "/index.html";
  return request;
}
