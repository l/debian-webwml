// GETs the given url, and schedules the callback to be invoked with the
// response body when it arrives.
//
// In case of problems the callback is invoked with an Error() argument,
// containing the error message.
// TODO: This is ugly, but how else to asynchronously deliver an exceptional
// condition?
//
// Args:
//   url: the url to GET
//   callback: the function to be invoked with the body or Error as an argument
function getTextAsync(url, callback) {
	var request = new XMLHttpRequest();
	request.onreadystatechange = function() {
		if (request.readyState !== 4)
			return;
		if (request.status === 200) {
			var type = request.getResponseHeader("Content-Type");
			if (type.match(/^text/))
				callback(request.responseText);
			else
				// TODO: i18nize
				callback(Error('Non-text response received'));
		} else	{
			if (request.statusText == "")
				// TODO: i18nize
				callback(Error("Unknown error"));
			else
				callback(Error(request.statusText));
		}
	};
	request.open("GET", url);
	request.send(null);
}

// Calculate the number of additions and removals in a diff text.
// Args:
//   diff: the text of the diff, optionally including the diff header (i.e. the
//   ---/+++ or other lines)
// Returns:
//   an array of two elements: number of added lines, number of removed lines.
//   On error a null is returned instead of the array
function diffstat(diff) {
	if (diff == null)
		return null;
	var first_hunk_offset = diff.indexOf("\n@@");
	var diff_text;
	if (first_hunk_offset > 0) {
		// Skip the ---/+++ in diff header.
		diff_text = diff.substring(first_hunk_offset);
	} else {
		diff_text = diff;
	}
	var changes = diff_text.match(/\n[+-]/g);
	if (changes == null) {
		return null;
	}
	function count_adds(i, str) { return str == "\n+" ? i + 1 : i }
	function count_dels(i, str) { return str == "\n-" ? i + 1 : i }
	var additions = changes.reduce(count_adds, 0);
	var removals = changes.reduce(count_dels, 0);
	return [additions, removals];
}

// Returns an HTML element presenting the given diff text or error object.
//
// Args:
//   diff_or_error: the diff text to pass to diffstat() or an error message
// Returns:
//   an HTML element, containing information about the argument
function diffstat_pretty(diff_or_error) {
	var topspan = document.createElement('span');
	topspan.setAttribute('style', 'font-family: monospace');
	if (diff_or_error instanceof Error) {
		var ret;
		ret = document.createElement('span');
		ret.setAttribute('title', diff_or_error.message);
		ret.innerHTML = ':-(';
		topspan.appendChild(ret);
	} else {
		var counts = diffstat(diff_or_error);
		if (counts == null) {
			var ret;
			ret = document.createElement('span');
			ret.setAttribute('title', 'parse error');
			ret.innerHTML = ':-(';
			topspan.appendChild(ret);
		} else {
			var ret;

			ret = document.createElement('span');
			ret.setAttribute('style', 'color: green');
			ret.innerHTML = '+' + counts[0];
			topspan.appendChild(ret);

		//	ret = document.createElement('br');
			ret = document.createTextNode('/');
			topspan.appendChild(ret);

			ret = document.createElement('span');
			ret.setAttribute('style', 'color: red');
			ret.innerHTML = '-' + counts[1];
			topspan.appendChild(ret);
		}
	}
	return topspan;
}	

// Replaces contents of element with diffstat information of the file between the revisions.
//
// Args:
//   path: path to the original file, relative to the english directory
//   r1, r2: the revision strings to compare
//   element: the element which is populated with the diffstat information
function setDiffstat(path, r1, r2, element) {
	// does not send CORS:
	// var base = "https://anonscm.debian.org/viewvc/webwml/webwml/";
	var base = "http://webwml.alioth.debian.org/cgi-bin/anoncvs-cors/";
	var lang = "english";
	var url = base + lang + "/" + path + "?r1=" + r1 + "&r2=" + r2 + "&view=patch";
	element.innerHTML = '...';
	getTextAsync(url, function(text) { element.replaceChild(diffstat_pretty(text), element.firstChild); });
}
