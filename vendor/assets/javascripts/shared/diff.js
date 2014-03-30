/* Copyright (c) 2006, 2008 Tony Garnock-Jones <tonyg@lshift.net>
 * Copyright (c) 2006, 2008 LShift Ltd. <query@lshift.net>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

Diff = {
    longest_common_subsequence: function(file1, file2, postprocessor) {
	/* Text diff algorithm following Hunt and McIlroy 1976.
         * J. W. Hunt and M. D. McIlroy, An algorithm for differential file
         * comparison, Bell Telephone Laboratories CSTR #41 (1976)
         * http://www.cs.dartmouth.edu/~doug/
         *
         * Expects two arrays of strings.
         */

	var equivalenceClasses = {};
	for (var j = 0; j < file2.length; j++) {
	    var line = file2[j];
	    if (equivalenceClasses[line]) {
		equivalenceClasses[line].push(j);
	    } else {
		equivalenceClasses[line] = [j];
	    }
	}

	var candidates = [{file1index: -1,
			   file2index: -1,
			   chain: null}];

	for (var i = 0; i < file1.length; i++) {
	    var line = file1[i];
	    var file2indices = equivalenceClasses[line] || [];

	    var r = 0;
	    var c = candidates[0];

	    for (var jX = 0; jX < file2indices.length; jX++) {
		var j = file2indices[jX];

		for (var s = 0; s < candidates.length; s++) {
		    if ((candidates[s].file2index < j) &&
			((s == candidates.length - 1) ||
			 (candidates[s + 1].file2index > j)))
			break;
		}

		if (s < candidates.length) {
		    var newCandidate = {file1index: i,
					file2index: j,
					chain: candidates[s]};
		    if (r == candidates.length) {
			candidates.push(c);
		    } else {
			candidates[r] = c;
		    }
		    r = s + 1;
		    c = newCandidate;
		    if (r == candidates.length) {
			break; // no point in examining further (j)s
		    }
		}
	    }

	    candidates[r] = c;
	}

	// At this point, we know the LCS: it's in the reverse of the
	// linked-list through .chain of
	// candidates[candidates.length - 1].

	return candidates[candidates.length - 1];
    },

    diff_comm: function(file1, file2) {
	// We apply the LCS to build a "comm"-style picture of the
	// differences between file1 and file2.

	var result = [];
	var tail1 = file1.length;
	var tail2 = file2.length;
	var common = {common: []};

	function processCommon() {
	    if (common.common.length) {
		common.common.reverse();
		result.push(common);
		common = {common: []};
	    }
	}

	for (var candidate = Diff.longest_common_subsequence(file1, file2);
	     candidate != null;
	     candidate = candidate.chain)
	{
	    var different = {file1: [], file2: []};

	    while (--tail1 > candidate.file1index) {
		different.file1.push(file1[tail1]);
	    }

	    while (--tail2 > candidate.file2index) {
		different.file2.push(file2[tail2]);
	    }

	    if (different.file1.length || different.file2.length) {
		processCommon();
		different.file1.reverse();
		different.file2.reverse();
		result.push(different);
	    }

	    if (tail1 >= 0) {
		common.common.push(file1[tail1]);
	    }
	}

	processCommon();

	result.reverse();
	return result;
    },

    diff_patch: function(file1, file2) {
	// We apply the LCD to build a JSON representation of a
	// diff(1)-style patch.

	var result = [];
	var tail1 = file1.length;
	var tail2 = file2.length;

	function chunkDescription(file, offset, length) {
	    var chunk = [];
	    for (var i = 0; i < length; i++) {
		chunk.push(file[offset + i]);
	    }
	    return {offset: offset,
		    length: length,
		    chunk: chunk};
	}

	for (var candidate = Diff.longest_common_subsequence(file1, file2);
	     candidate != null;
	     candidate = candidate.chain)
	{
	    var mismatchLength1 = tail1 - candidate.file1index - 1;
	    var mismatchLength2 = tail2 - candidate.file2index - 1;
	    tail1 = candidate.file1index;
	    tail2 = candidate.file2index;

	    if (mismatchLength1 || mismatchLength2) {
		result.push({file1: chunkDescription(file1,
						     candidate.file1index + 1,
						     mismatchLength1),
			     file2: chunkDescription(file2,
						     candidate.file2index + 1,
						     mismatchLength2)});
	    }
	}

	result.reverse();
	return result;
    },

    invert_patch: function(patch) {
	// Takes the output of Diff.diff_patch(), and inverts the
	// sense of it, so that it can be applied to file2 to give
	// file1 rather than the other way around.

	for (var i = 0; i < patch.length; i++) {
	    var chunk = patch[i];
	    var tmp = chunk.file1;
	    chunk.file1 = chunk.file2;
	    chunk.file2 = tmp;
	}
    },

    patch: function (file, patch) {
	// Applies a patch to a file.
	//
	// Given file1 and file2, Diff.patch(file1,
	// Diff.diff_patch(file1, file2)) should give file2.

	var result = [];
	var commonOffset = 0;

	function copyCommon(targetOffset) {
	    while (commonOffset < targetOffset) {
		result.push(file[commonOffset++]);
	    }
	}

	for (var chunkIndex = 0; chunkIndex < patch.length; chunkIndex++) {
	    var chunk = patch[chunkIndex];
	    copyCommon(chunk.file1.offset);
	    for (var lineIndex = 0; lineIndex < chunk.file2.length; lineIndex++) {
		result.push(chunk.file2.chunk[lineIndex]);
	    }
	    commonOffset += chunk.file1.length;
	}

	copyCommon(file.length);
	return result;
    },

    diff_indices: function(file1, file2) {
	// We apply the LCS to give a simple representation of the
	// offsets and lengths of mismatched chunks in the input
	// files. This is used by diff3_merge_indices below.

	var result = [];
	var tail1 = file1.length;
	var tail2 = file2.length;

	for (var candidate = Diff.longest_common_subsequence(file1, file2);
	     candidate != null;
	     candidate = candidate.chain)
	{
	    var mismatchLength1 = tail1 - candidate.file1index - 1;
	    var mismatchLength2 = tail2 - candidate.file2index - 1;
	    tail1 = candidate.file1index;
	    tail2 = candidate.file2index;

	    if (mismatchLength1 || mismatchLength2) {
		result.push({file1: [tail1 + 1, mismatchLength1],
			     file2: [tail2 + 1, mismatchLength2]});
	    }
	}

	result.reverse();
	return result;
    },

    diff3_merge_indices: function (a, o, b) {
	// Given three files, A, O, and B, where both A and B are
	// independently derived from O, returns a fairly complicated
	// internal representation of merge decisions it's taken. The
	// interested reader may wish to consult
	//
	// Sanjeev Khanna, Keshav Kunal, and Benjamin C. Pierce. "A
	// Formal Investigation of Diff3." In Arvind and Prasad,
	// editors, Foundations of Software Technology and Theoretical
	// Computer Science (FSTTCS), December 2007.
	//
	// (http://www.cis.upenn.edu/~bcpierce/papers/diff3-short.pdf)

	var m1 = Diff.diff_indices(o, a);
	var m2 = Diff.diff_indices(o, b);

	var hunks = [];
	function addHunk(h, side) {
	    hunks.push([h.file1[0], side, h.file1[1], h.file2[0], h.file2[1]]);
	}
	for (var i = 0; i < m1.length; i++) { addHunk(m1[i], 0); }
	for (var i = 0; i < m2.length; i++) { addHunk(m2[i], 2); }
	hunks.sort();

	var result = [];
	var commonOffset = 0;
	function copyCommon(targetOffset) {
	    if (targetOffset > commonOffset) {
		result.push([1, commonOffset, targetOffset - commonOffset]);
		commonOffset = targetOffset;
	    }
	}

	for (var hunkIndex = 0; hunkIndex < hunks.length; hunkIndex++) {
	    var firstHunkIndex = hunkIndex;
	    var hunk = hunks[hunkIndex];
	    var regionLhs = hunk[0];
	    var regionRhs = regionLhs + hunk[2];
	    while (hunkIndex < hunks.length - 1) {
		var maybeOverlapping = hunks[hunkIndex + 1];
		var maybeLhs = maybeOverlapping[0];
		if (maybeLhs >= regionRhs) break;
		regionRhs = maybeLhs + maybeOverlapping[2];
		hunkIndex++;
	    }

	    copyCommon(regionLhs);
	    if (firstHunkIndex == hunkIndex) {
		if (hunk[4] > 0) {
		    result.push([hunk[1], hunk[3], hunk[4]]);
		}
	    } else {
		var regions = [a.length, -1, regionLhs, regionRhs, b.length, -1];
		for (var i = firstHunkIndex; i <= hunkIndex; i++) {
		    var side = hunks[i][1];
		    var lhs = hunks[i][3];
		    var rhs = lhs + hunks[i][4];
		    var ri = side * 2;
		    regions[ri] = Math.min(lhs, regions[ri]);
		    regions[ri+1] = Math.max(rhs, regions[ri+1]);
		}
		result.push([-1,
			     regions[0], regions[1] - regions[0],
			     regions[2], regions[3] - regions[2],
			     regions[4], regions[5] - regions[4]]);
	    }
	    commonOffset = regionRhs;
	}

	copyCommon(o.length);
	return result;
    },

    diff3_merge: function (a, o, b, excludeFalseConflicts) {
	// Applies the output of Diff.diff3_merge_indices to actually
	// construct the merged file; the returned result alternates
	// between "ok" and "conflict" blocks.

	var result = [];
	var files = [a, o, b];
	var indices = Diff.diff3_merge_indices(a, o, b);

	var okLines = [];
	function flushOk() {
	    if (okLines) {
		result.push({ok: okLines});
	    }
	    okLines = [];
	}
	function pushOk(xs) {
	    for (var j = 0; j < xs.length; j++) {
		okLines.push(xs[j]);
	    }
	}

	function isTrueConflict(rec) {
	    if (rec[2] != rec[6]) return true;
	    var aoff = rec[1];
	    var boff = rec[5];
	    for (var j = 0; j < rec[2]; j++) {
		if (a[j + aoff] != b[j + boff]) return true;
	    }
	    return false;
	}

	for (var i = 0; i < indices.length; i++) {
	    var x = indices[i];
	    var side = x[0];
	    if (side == -1) {
		if (excludeFalseConflicts && !isTrueConflict(x)) {
		    pushOk(files[0].slice(x[1], x[1] + x[2]));
		} else {
		    flushOk();
		    result.push({conflict: {a: a.slice(x[1], x[1] + x[2]),
					    aIndex: x[1],
					    o: o.slice(x[3], x[3] + x[4]),
					    oIndex: x[3],
					    b: b.slice(x[5], x[5] + x[6]),
					    bIndex: x[5]}});
		}
	    } else {
		pushOk(files[side].slice(x[1], x[1] + x[2]));
	    }
	}

	flushOk();
	return result;
    }
}
