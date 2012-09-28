// If the page's hash seems to be a bug number redirect to
// http://bugs.debian.org/<hash>
if (document.location.hash.match(/^#\d+$/)) {
    document.location = "http://bugs.debian.org/" + document.location.hash.substring(1);
}
