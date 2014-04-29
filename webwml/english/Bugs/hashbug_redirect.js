// If the page's hash seems to be a bug number redirect to
// https://bugs.debian.org/<hash>
if (document.location.hash.match(/^#\d+$/)) {
    document.location = "https://bugs.debian.org/" + document.location.hash.substring(1);
}
