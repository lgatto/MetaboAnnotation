library(Spectra)
df1 <- DataFrame(
    msLevel = 2L, rtime = 1:10,
    spectrum_id = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"))
df2 <- DataFrame(
    msLevel = 2L, rtime = rep(1:10, 20),
    spectrum_id = rep(c("A", "B", "C", "D", "E"), 20))
sp1 <- Spectra(df1)
sp2 <- Spectra(df2)

test_that("validator work", {
    ## .validate_matches_format
    res <- .validate_matches_format(4)
    expect_match(res, "data.frame")
        res <- .validate_matches_format(data.frame())
    expect_match(res, "Not all ")
    tmp <- data.frame(query_idx = 1:3, target_idx = 1:6, score = 12)
    res <- .validate_matches_format(tmp)
    expect_equal(res, NULL)
    tmp$query_idx <- "a"
    res <- .validate_matches_format(tmp)
    expect_match(res, "query_idx")
    tmp$query_idx <- 1:6
    tmp$target_idx <- "a"
    res <- .validate_matches_format(tmp)
    expect_match(res, "target_idx")

    ## .validate_matches_content
    tmp$target_idx <- c(1:3, 1:3)
    res <- .validate_matches_content(tmp, 3, 3)
    expect_match(res, "query_idx")
    res <- .validate_matches_content(tmp, 9, 2)
    expect_match(res, "target_idx")
    res <- .validate_matches_content(tmp, 10, 10)
    expect_equal(res, NULL)
})

test_that("MatchedSpectra works", {
    ms <- MatchedSpectra()
    expect_true(validObject(ms))
    expect_output(show(ms), "MatchedSpectra")
    expect_true(is(query(ms), "Spectra"))
    expect_true(is(target(ms), "Spectra"))
    expect_equal(whichQuery(ms), integer())
    expect_equal(whichTarget(ms), integer())
    
    ## With data
    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    expect_true(validObject(ms))
    expect_true(length(ms) == 6)
    expect_output(show(ms), "5 matched")
    expect_true(is(query(ms), "Spectra"))
    expect_true(is(target(ms), "Spectra"))
    expect_equal(whichQuery(ms), c(1L, 2L, 4L))
    expect_equal(whichTarget(ms), c(2L, 5L, 8L, 12L, 15L))
})

test_that(".subset_matches_nodim and [ works", {
    ms <- MatchedSpectra()
    expect_error(.subset_matches_nodim(ms, 1), "out-of-bounds")
    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    res <- .subset_matches_nodim(ms, 2)
    expect_true(length(res) == 1)
    expect_equal(res@matches$query_idx, 1L)
    expect_equal(res@matches$target_idx, ms@matches$target_idx[3])
    expect_equal(res@matches$score, ms@matches$score[3])
    expect_equal(res@query, ms@query[2])
    expect_equal(res@target, ms@target)

    expect_error(.subset_matches_nodim(ms, 12), "out of bounds")

    res <- .subset_matches_nodim(ms, c(2, 4))
    expect_equal(res@query, ms@query[c(2, 4)])
    expect_true(length(res) == 4)
    expect_equal(res@matches$score, 3:6)
    
    ## duplicated index
    res <- .subset_matches_nodim2(ms, c(2, 4, 2))
    expect_true(length(res) == 5)
    expect_equal(res@matches$score, c(3, 4, 5, 6, 3))
    expect_equal(query(res), query(ms)[c(2, 4, 2)])
    expect_equal(target(res), target(ms))
    
    ## arbitrary order
    res <- .subset_matches_nodim(ms, c(3, 2, 1, 1, 6, 9))
    expect_equal(query(res), query(ms)[c(3, 2, 1, 1, 6, 9)])
    expect_equal(target(res), target(ms))
    expect_equal(res@matches$query_idx, c(2L, 3L, 3L, 4L, 4L))
    expect_equal(res@matches$score, c(3, 1, 2, 1, 2))

    res <- ms[]
    expect_equal(res, ms)
    res <- ms[c(FALSE, TRUE)]
    expect_equal(res@matches$query_idx, 1L)
    expect_equal(res@matches$target_idx, 2L)
    expect_equal(res@matches$score, 3)

    ## All works even after subsetting and pruning.
    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    res <- ms[whichQuery(ms)]
    expect_equal(res$spectrum_id, c("a", "a", "b", "d", "d", "d"))
    res <- pruneTarget(res)
})

test_that(".fill_index works", {
    res <- .fill_index(1:5, integer())
    expect_equal(res, 1:5)

    res <- .fill_index(1:20, c(2, 4, 4, 4, 6, 9, 10))
    expect_equal(res, c(1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
                        14, 15, 16, 17, 18, 19, 20))
})

test_that("$,MatchedSpectra works", {
    ms <- MatchedSpectra()
    expect_equal(ms$msLevel, integer())
    expect_equal(ms$target_msLevel, integer())

    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    res <- ms$rtime
    expect_equal(res, c(1, 1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10))
    res <- ms$target_rtime
    expect_equal(res, c(2, 5, 2, NA, 8, 2, 5, NA, NA, NA, NA, NA, NA))
    res <- ms$score
    expect_equal(res, c(1, 2, 3, NA, 4, 5, 6, NA, NA, NA, NA, NA, NA))
    
    ## A MatchedSpectra with no matching target spectra
    ms <- MatchedSpectra(sp1, sp2, matches = data.frame(query_idx = integer(),
                                                        target_idx = integer(),
                                                        score = numeric()))
    res <- ms$rtime
    expect_equal(res, 1:10)
    res <- ms$target_rtime
    expect_true(all(is.na(res)))
    res <- ms$score
    expect_true(all(is.na(res)))    
})

test_that("spectraData,MatchedSpectra works", {
    ms <- MatchedSpectra()
    res <- spectraData(ms)
    expect_true(is(res, "DataFrame"))
    expect_true(nrow(res) == 0)
    expect_equal(colnames(res), spectraVariables(ms))

    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    res <- spectraData(ms)
    expect_equal(res$rtime, c(1, 1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10))
    expect_equal(res$target_rtime,
                 c(2, 5, 2, NA, 8, 2, 5, NA, NA, NA, NA, NA, NA))
    expect_equal(res$score, c(1, 2, 3, NA, 4, 5, 6, NA, NA, NA, NA, NA, NA))
    
    expect_error(spectraData(ms, columns = "other"), "other not available")

    
    ## Only query spectra variables
    res <- spectraData(ms, columns = c("rtime", "spectrum_id", "msLevel"))
    expect_equal(colnames(res), c("rtime", "spectrum_id", "msLevel"))
    expect_equal(res$rtime, c(1, 1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10))
    
    ## Only target spectra variables
    res <- spectraData(ms, columns = c("target_rtime", "target_spectrum_id"))
    expect_equal(colnames(res), c("target_rtime", "target_spectrum_id"))
    expect_equal(res$target_rtime,
                 c(2, 5, 2, NA, 8, 2, 5, NA, NA, NA, NA, NA, NA))

    ## Only matches
    res <- spectraData(ms, columns = c("score"))
    expect_equal(colnames(res), c("score"))
    expect_equal(res$score,
                 c(1, 2, 3, NA, 4, 5, 6, NA, NA, NA, NA, NA, NA))
    
    ## A MatchedSpectra with no matching target spectra
    ms <- MatchedSpectra(sp1, sp2, matches = data.frame(query_idx = integer(),
                                                        target_idx = integer(),
                                                        score = numeric()))
    res <- spectraData(ms)
    expect_equal(res$rtime, 1:10)
    expect_true(all(is.na(res$target_rtime)))

    ## Only query spectra variables
    res <- spectraData(ms, columns = c("rtime", "spectrum_id", "msLevel"))
    expect_equal(colnames(res), c("rtime", "spectrum_id", "msLevel"))
    expect_equal(res$rtime, 1:10)

    ## Only target spectra variables
    res <- spectraData(ms, columns = c("target_rtime", "target_spectrum_id"))
    expect_true(nrow(res) == 10)
    expect_equal(colnames(res), c("target_rtime", "target_spectrum_id"))
    expect_true(all(is.na(res$target_rtime)))

    ## Only matches
    res <- spectraData(ms, columns = c("score"))
    expect_equal(colnames(res), c("score"))
    expect_true(all(is.na(res$score)))
})

test_that("pruneTarget,MatchedSpectra works", {
    ms <- MatchedSpectra()
    res <- pruneTarget(ms)
    expect_true(is(res, "MatchedSpectra"))
    expect_equal(res, ms)

    ms <- MatchedSpectra(
        sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
                                       target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
                                       score = 1:6))
    res <- pruneTarget(ms)
    expect_equal(spectraData(res), spectraData(ms))
    expect_true(length(res@target) < length(ms@target))

    ms <- MatchedSpectra(sp1, sp2, matches = data.frame(query_idx = integer(),
                                                        target_idx = integer(),
                                                        score = numeric()))
    res <- pruneTarget(ms)
    expect_equal(spectraData(res), spectraData(ms))
    expect_true(length(res@target) < length(ms@target))    
})

test_that("plotSpectraMirror throws an error") {
    expect_error(plotSpectraMirror(ms), "Length")
}
