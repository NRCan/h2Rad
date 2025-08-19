#' @title deepTimeSum
#'
#' @description
#' Summarizes the output of deepTimeProd() function into cumulative min/max/mean of produced hydrogen and helium over the specified model duration
#'
#' @param deepTimeProdDF Output dataframe of the deepTimeProd()
#'
#' @examples
#' data("monteDataLithCat")
#' df <- monteProd(lithCat,1000)
#' dfTime <- deepTimeProd(df,1,100,1)
#' deepTimeSum(dfTime)
#'
#' @export
deepTimeSum <- function(deepTimeProdDF){
  sumDeepDF <- deepTimeProdDF %>%
    group_by(Sample) %>%
    summarize(H2MinProdCum=sum(H2MinProd),
              H2MeanProdCum=sum(H2MeanProd),
              H2MaxProdCum=sum(H2MaxProd),
              HeMinProdCum=sum(HeMinProd),
              HeMeanProdCum=sum(HeMeanProd),
              HeMaxProdCum=sum(HeMaxProd))

  sumDeepDF
}
