#' @title Representation of Spectra matches
#'
#' @name MatchedSpectra
#' 
#' @aliases MatchedSpectra MatchedSpectra-class
#' 
#' @description
#' 
#' Matches between query and target spectra can be represented by the
#' `MatchedSpectra` object. Functions like the [matchSpectra()] function will
#' return this type of object. By default, all data accessors work as
#' *left joins* between the *query* and the *target* spectra, i.e. values are
#' returned for each *query* spectrum with eventual duplicated entries (values)
#' if the query spectrum matches more than one target spectrum. 
#'
#' @section Creation and subsetting:
#'
#' `MatchedSpectra` objects can be created with the `MatchedSpectra` function
#' providing the `query` and `target` `Spectra` as well as a `data.frame` with
#' the
#'
#' - `[` subset the `MatchedSpectra` selecting `query` spectra to keep with
#'   parameter `i`. The `target` spectra will by default be returned as-is.
#' 
#' - `pruneTarget` *cleans* the `MatchedSpectra` object by removing non-matched
#'   target spectra.
#' 
#' @section Extracting data:
#'
#' - `$` extracts a single spectra variable from the `MatchedSpectra` `x`. Use
#'   `spectraVariables` to get all available spectra variables. Prefix
#'   `"target_"` is used for spectra variables from the *target* `Spectra`. The
#'   matching scores are available as *spectra variable* `"score"`.
#'   Similar to a left join between the query and target spectra, this function
#'   returns a value for each query spectrum with eventual duplicated values for
#'   query spectra matching more than one target spectrum. If spectra variables
#'   from the target spectra are extracted, an `NA` is reported for *query*
#'   spectra that don't match any target spectra. See examples below for more
#'   details.
#' 
#' - `length` returns the number of **query** spectra.
#'
#' - `spectraData` returns spectra variables from the query and/or target
#'   `Spectra` as a `DataFrame`. Parameter `columns` allows to define which
#'   variables should be returned (defaults to
#'   `columns = spectraVariables(object)`), spectra variable names of the target
#'   spectra need to be prefixed with `target_` (e.g. `target_msLevel` to get
#'   the MS level from target spectra). The score from the matching function is
#'   returned as spectra variable `"score"`. Similar to `$`, this function
#'   performs a *left join* of spectra variables from the *query* and *target*
#'   spectra returning all values for all query spectra (eventually returning
#'   duplicated elements for query spectra matching multiple target spectra)
#'   and the values for the target spectra matched to the respective query
#'   spectra. See help on `$` above or examples below for details.
#' 
#' - `spectraVariables` returns all available spectra variables in the *query*
#'   and *target* spectra. The prefix `"target_"` is used to label spectra
#'   variables of target spectra (e.g. the name of the spectra variable for the
#'   MS level of target spectra is called `"target_msLevel"`).  
#' 
#' - `target` returns the *target* `Spectra`.
#' 
#' - `query` returns the *query* `Spectra`.
#'
#' - `whichTarget` returns an `integer` with the indices of the spectra in
#'   *target* that match at least on spectrum in *query*.
#'
#' - `whichQuery` returns an `integer` with the indices of the spectra in
#'   *query* that match at least on spectrum in *target*.
#'
#' @section Data manipulation and plotting:
#'
#' - `addProcessing`: add a processing step to both the *query* and *target*
#'   `Spectra` in `object`. Additional parameters for `FUN` can be passed *via*
#'   `...`. See `addProcessing` documentation in [Spectra()] for more
#'   information.
#'
#' - `plotSpectraMirror`: creates a mirror plot between the query and each
#'   matching target spectrum. Can only be applied to a `MatchedSpectra` with a
#'   single query spectrum.
#'
#' @param columns for `spectraData`: `character` vector with spectra variable
#'   names that should be extracted.
#' 
#' @param drop for `[`: ignored.
#' 
#' @param FUN For `addProcessing`: function to be applied to the peak matrix
#'   of each spectrum in `object`. See [Spectra()] for more details.
#'
#' @param i `integer` or `logical` defining the `query` spectra to keep.
#'
#' @param j for `[`: ignored.
#'
#' @param main for `plotSpectraMirror`: an optional title for each plot.
#' 
#' @param matches `data.frame` with columns `"query_idx"` (`integer`),
#'   `"target_idx"` (`integer`) and `"score"` (`numeric`) representing the
#'   *n:m* mapping of elements between the `query` and the `target` `Spectra`.
#'
#' @param name for `$`: the name of the spectra variable to extract.
#' 
#' @param object `MatchedSpectra` object.
#' 
#' @param spectraVariables For `addProcessing`: `character` with additional
#'   spectra variables that should be passed along to the function defined
#'   with `FUN`. See [Spectra()] for details.
#'
#' @param target `Spectra` with the spectra against which `query` has been
#'   matched.
#'
#' @param query `Spectra` with the query spectra.
#'
#' @param x `MatchedSpectra` object.
#'
#' @param xlab for `plotSpectraMirror`: the label for the x-axis.
#'
#' @param ylab for `plotSpectraMirror`: the label for the y-axis.
#'
#' @param ... for `addProcessing`: additional parameters for the function `FUN`.
#'
#' @return See individual method desciption above for details.
#' 
#' @importClassesFrom Spectra Spectra
#'
#' @importFrom Spectra Spectra
#' 
#' @exportClass MatchedSpectra
#'
#' @author Johannes Rainer
#' 
#' @rdname MatchedSpectra
#'
#' @examples
#'
#' ## Creating a dummy MatchedSpectra object.
#' library(Spectra)
#' df1 <- DataFrame(
#'     msLevel = 2L, rtime = 1:10,
#'     spectrum_id = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j"))
#' df2 <- DataFrame(
#'     msLevel = 2L, rtime = rep(1:10, 20),
#'     spectrum_id = rep(c("A", "B", "C", "D", "E"), 20))
#' sp1 <- Spectra(df1)
#' sp2 <- Spectra(df2)
#' ## Define matches between query spectrum 1 with target spectra 2 and 5,
#' ## query spectrum 2 with target spectrum 2 and query spectrum 4 with target
#' ## spectra 8, 12 and 15.
#' ms <- MatchedSpectra(
#'     sp1, sp2, matches = data.frame(query_idx = c(1L, 1L, 2L, 4L, 4L, 4L),
#'                                    target_idx = c(2L, 5L, 2L, 8L, 12L, 15L),
#'                                    score = 1:6))
#' 
#' ## Which of the query spectra match at least one target spectrum?
#' whichQuery(ms)
#'
#' ## Extracting spectra variables: accessor methods for spectra variables act
#' ## as "left joins", i.e. they return a value for each query spectrum, with
#' ## eventually duplicated elements if one query spectrum matches more than
#' ## one target spectrum.
#' 
#' ## Which target spectrum matches at least one query spectrum?
#' whichTarget(ms)
#' 
#' ## Extracting the retention times of the query spectra.
#' ms$rtime
#'
#' ## We have duplicated retention times for query spectrum 1 (matches 2 target
#' ## spectra) and 4 (matches 3 target spectra). The retention time is returned
#' ## for each query spectrum.
#'
#' ## Extracting retention times of the target spectra. Note that only retention
#' ## times for target spectra matching at least one query spectrum are returned
#' ## and an NA is reported for query spectra without matching target spectrum.
#' ms$target_rtime
#'
#' ## The first query spectrum matches target spectra 2 and 5, thus their
#' ## retention times are returned as well as the retention time of the second
#' ## target spectrum that matches also query spectrum 2. The 3rd query spectrum
#' ## does match any target spectrum, thus `NA` is returned. Query spectrum 4
#' ## matches target spectra 8, 12, and 15, thus the next reported retention
#' ## times are those from these 3 target spectra. None of the remaining 6 query
#' ## spectra matches any target spectra and thus `NA` is reported for each of
#' ## them.
#'
#' ## `spectraData` can be used to extract all (or selected) spectra variables
#' ## from the object. Same as with `$`, a left join between the specta
#' ## variables from the query spectra and the target spectra is performed. The
#' ## prefix `"target_"` is used to label the spectra variables from the target
#' ## spectra. Below we extract selected spectra variables from the object.
#' res <- spectraData(ms, columns = c("rtime", "spectrum_id",
#'     "target_rtime", "target_spectrum_id"))
#' res
#' res$spectrum_id
#' res$target_spectrum_id
#'
#' ## Again, all values for query spectra are returned and for query spectra not
#' ## matching any target spectrum NA is reported as value for the respecive
#' ## variable.
#'
#' ## The example matched spectra object contains all query and all target
#' ## spectra. Below we subset the object keeping only query spectra that are
#' ## matched to at least one target spectrum.
#' ms_sub <- ms[whichQuery(ms)]
#'
#' ## ms_sub contains now only 3 query spectra:
#' length(query(ms_sub))
#'
#' ## while the original object contains all 10 query spectra:
#' length(query(ms))
#'
#' ## Both object contain however still the full target `Spectra`:
#' length(target(ms))
#' length(target(ms_sub))
#'
#' ## With the `pruneTarget` we can however reduce also the target spectra to
#' ## only those that match at least one query spectrum
#' ms_sub <- pruneTarget(ms_sub)
#' length(target(ms_sub))
NULL

setClass(
    "MatchedSpectra",
    slots = c(
        query = "Spectra",
        target = "Spectra",
        matches = "data.frame",
        ## metadata
        metadata = "list",
        version = "character"
    ),
    prototype = prototype(
        query = Spectra(),
        target = Spectra(),
        matches = data.frame(query_idx = integer(),
                             target_idx = integer(),
                             score = numeric()),
        metadata = list(),
        version = "0.1")
)

#' @export
#'
#' @rdname MatchedSpectra
MatchedSpectra <- function(query = Spectra(), target = Spectra(),
                           matches = data.frame(query_idx = integer(),
                                                target_idx = integer(),
                                                score = numeric())) {
    new("MatchedSpectra", query = query, target = target, matches = matches)
}

setValidity("MatchedSpectra", function(object) {
    msg <- .validate_matches_format(object@matches)
    if (length(msg)) return(msg)
    msg <- .validate_matches_content(object@matches, length(object@query),
                                     length(object@target))
    if (length(msg)) return(msg)
    TRUE
})

#' @export
#'
#' @rdname MatchedSpectra
setMethod("length", "MatchedSpectra", function(x) length(x@query))

#' @exportMethod show
#'
#' @importMethodsFrom methods show
#'
#' @rdname MatchedSpectra
setMethod("show", "MatchedSpectra", function(object) {
    cat("Object of class", class(object)[1L], "\n")
    cat("Total number of matches:", nrow(object@matches), "\n")
    cat("Number of query spectra: ", length(object@query), " (",
        length(unique(object@matches$query_idx)), " matched)\n", sep = "")
    cat("Number of target spectra: ", length(object@target), " (",
        length(unique(object@matches$target_idx)), " matched)\n", sep = "")
})

#' @exportMethod [
#'
#' @rdname MatchedSpectra
setMethod("[", "MatchedSpectra", function(x, i, j, ..., drop = FALSE) {
    if (missing(i))
        return(x)
    if (is.logical(i))
        i <- which(i)
    .subset_matches_nodim(x, i)
})

#' @rdname MatchedSpectra
#' 
#' @export
target <- function(object) {
    object@target
}

#' @rdname MatchedSpectra
#' 
#' @export
query <- function(object) {
    object@query
}

#' @rdname MatchedSpectra
#' 
#' @export
whichTarget <- function(object) {
    unique(object@matches$target_idx)
}

#' @rdname MatchedSpectra
#' 
#' @export
whichQuery <- function(object) {
    unique(object@matches$query_idx)
}

#' @importMethodsFrom ProtGenerics spectraVariables
#'
#' @rdname MatchedSpectra
#' 
#' @export
setMethod("spectraVariables", "MatchedSpectra", function(object) {
    svq <- spectraVariables(query(object))
    svt <- spectraVariables(target(object))
    cns <- colnames(object@matches)
    c(svq, paste0("target_", svt), cns[!cns %in% c("query_idx", "target_idx")])
})

#' @importMethodsFrom S4Vectors $
#'
#' @rdname MatchedSpectra
#' 
#' @export
setMethod("$", "MatchedSpectra", function(x, name) {
    idxs <- .fill_index(seq_along(x@query), x@matches$query_idx)
    if (name %in% colnames(x@matches)) {
        keep <- idxs %in% x@matches$query_idx
        idxs[keep] <- seq_len(sum(keep))
        idxs[!keep] <- NA
        return(x@matches[idxs, name])
    }
    if (length(grep("^target_", name))) {
        vals <- do.call("$", list(x@target[x@matches$target_idx],
                                  sub("target_", "", name)))
        keep <- idxs %in% x@matches$query_idx
        idxs[keep] <- seq_len(sum(keep))
        idxs[!keep] <- NA
        vals[idxs]
    } else
        do.call("$", list(x@query, name))[idxs]
})

#' @importMethodsFrom S4Vectors cbind
#'
#' @importMethodsFrom Spectra spectraData
#'
#' @importFrom S4Vectors DataFrame
#' 
#' @rdname MatchedSpectra
#'
#' @export
setMethod(
    "spectraData",
    "MatchedSpectra", function(object, columns = spectraVariables(object)) {
        if (any(!columns %in% spectraVariables(object)))
            stop("column(s) ", paste0(columns[!columns %in%
                                              spectraVariables(object)],
                                      collapse = ", "), " not available")
        idxs <- .fill_index(seq_along(object@query), object@matches$query_idx)
        from_target <- grepl("^target_", columns)
        from_matches <- columns %in% colnames(object@matches)
        from_query <- !(from_target | from_matches)
        res <- DataFrame()
        if (any(from_query))
            res <- spectraData(
                object@query,
                columns = columns[from_query])[idxs, , drop = FALSE]
        if (any(from_target)) {
            spt <- spectraData(object@target[object@matches$target_idx],
                               columns = sub("target_", "",
                                             columns[from_target]))
            colnames(spt) <- paste0("target_", colnames(spt))
            keep <- idxs %in% object@matches$query_idx
            target_idxs <- idxs
            target_idxs[keep] <- seq_len(sum(keep))
            target_idxs[!keep] <- NA
            if (nrow(res) == length(idxs))
                res <- cbind(res, spt[target_idxs, , drop = FALSE])
            else res <- spt[target_idxs, , drop = FALSE]
        }
        if (any(from_matches)) {
            keep <- idxs %in% object@matches$query_idx
            idxs[keep] <- seq_len(sum(keep))
            idxs[!keep] <- NA
            if (nrow(res) == length(idxs))
                res <- cbind(res,
                             DataFrame(object@matches[idxs,
                                                      columns[from_matches],
                                                      drop = FALSE]))
            else res <- DataFrame(object@matches[idxs,
                                                 columns[from_matches],
                                                 drop = FALSE])
        }
        res[, columns, drop = FALSE]
    })

.fill_index <- function(x, y) {
    sort(c(setdiff(x, y), y))
}

#' @rdname MatchedSpectra
#'
#' @importFrom methods validObject
#' 
#' @export
pruneTarget <- function(object) {
    keep <- whichTarget(object)
    object@target <- object@target[keep]
    object@matches$target_idx <- match(object@matches$target_idx, keep)
    validObject(object)
    object
}

.validate_matches_format <- function(x) {
    msg <- NULL
    if (!is.data.frame(x))
        msg <- c(msg, "'matches' should be a 'data.frame'")
    else {
        if (!all(c("query_idx", "target_idx", "score") %in% colnames(x)))
            return(c(msg, paste0("Not all required column names \"query_idx\",",
                                 " \"target_idx\" and \"score\" found in",
                                 " 'matches'")))
        if (!is.integer(x$target_idx))
            msg <- c(msg,
                     "column \"target_idx\" is expected to be of type integer")
        if (!is.integer(x$query_idx))
            msg <- c(msg,
                     "column \"query_idx\" is expected to be of type integer")
    }
    msg
}

.validate_matches_content <- function(x, nquery, ntarget) {
    msg <- NULL
    if (!all(x$query_idx %in% seq_len(nquery)))
        msg <- c(msg, "indices in \"query_idx\" are out of bounds")
    if (!all(x$target_idx %in% seq_len(ntarget)))
        msg <- c(msg, "indices in \"target_idx\" are out of bounds")
    msg
}

#' Subsetting of a matched object with slots query, target and matches. Should
#' work on all such objects for which `target` and `query` don't have dimensions
#'
#' @param i has to be an `integer` vector with the indices of the query elements
#'     to keep.
#' 
#' @importFrom methods slot<-
#'
#' @noRd
.subset_matches_nodim <- function(x, i) {
    slot(x, "query", check = FALSE) <- x@query[i]
    mtches <- x@matches[x@matches$query_idx %in% i, , drop = FALSE]
    ## Support handling duplicated indices.
    mtches <- split.data.frame(
        x@matches, f = as.factor(x@matches$query_idx))[as.character(i)]
    lns <- vapply(mtches, function(z)
        if (length(z)) nrow(z) else 0L, integer(1))
    mtches <- do.call(rbind, mtches[lengths(mtches) > 0])
    rownames(mtches) <- NULL
    mtches$query_idx <- rep(seq_along(i), lns)
    slot(x, "matches", check = FALSE) <- mtches
    x
}

#' @importMethodsFrom Spectra addProcessing
#'
#' @rdname MatchedSpectra
#'
#' @export
setMethod(
    "addProcessing", "MatchedSpectra",
    function(object, FUN, ..., spectraVariables = character()) {
        if (missing(FUN))
            return(object)
        object@query <- addProcessing(object@query, FUN = FUN, ...,
                                      spectraVariables = spectraVariables)
        object@target <- addProcessing(object@target, FUN = FUN, ...,
                                       spectraVariables = spectraVariables)
        object
    })

#' @importMethodsFrom Spectra plotSpectraMirror
#'
#' @rdname MatchedSpectra
#'
#' @importFrom graphics par
#' 
#' @export
setMethod("plotSpectraMirror", "MatchedSpectra", function(x, xlab = "m/z",
                                                          ylab = "intensity",
                                                          main = "") {
    if (length(query(x)) != 1)
        stop("Length of 'query(x)' has to be 1.")
    y <- x@target[x@matches$target_idx]
    if (!length(y))
        y <- Spectra(DataFrame(msLevel = 2L))
    nr <- ceiling(sqrt(max(length(y), 1)))
    par(mfrow = c(nr, nr))
    for (i in seq_along(y))
        plotSpectraMirror(x = query(x)[1L], y = y[i],
                          xlab = xlab, ylab = ylab, main = main)
})
