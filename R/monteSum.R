#' @title monteSum
#'
#' @description
#' Returns a summarized dataframe (one row per sample) from the output dataframe of the monteProd() function.
#'
#' @details
#' This function uses a "groupby() %>% summaize()" to produce a min/max/mean/standard deviation for both the hydrogen production and helium production of the input samples.  Production rates (columns ending in H2 and He) are in rates of mols gas / m3 / year following Warr et al. (2023).
#'
#' @param modelDF Monte Carlo model dataframe produced by the monteProd() function.
#'
#' @examples
#' data("monteDataLithCat")
#' df <- monteProd(lithCat,1000)
#' monteSum(df)
#'
#' @export
monteSum <- function(modelDF){
  sumDF <- modelDF %>% group_by(Sample) %>% summarize(minH2=min(H2total),
                                                      maxH2=max(H2total),
                                                      meanH2=mean(H2total),
                                                      sdH2=sd(H2total),
                                                      minHe=min(Hetotal),
                                                      maxHe=max(Hetotal),
                                                      meanHe=mean(Hetotal),
                                                      sdHe=sd(Hetotal))

  otherCats <- modelDF %>% select(colnames(modelDF)[(!colnames(modelDF)  %in% c("litLith", "rockDenMin", "rockDenMax", "rockDenMean", "rockDenSD", "porMin", "porMax", "porMean", "porSD", "fluDenMin", "fluDenMax", "fluDenMean", "fluDenSD", "uMin", "uMax", "uMean", "uSD", "thMin", "thMax", "thMean", "thSD", "kMin", "kMax" ,"kMean", "kSD", "rockDen", "porosity", "fluDen", "Uppm", "Thppm", "Kpct", "sysDen", "W", "EKA", "EKB", "EKG", "EThA", "EThB", "EThG",  "EUA", "EUB", "EUG", "ENetA", "ENetB", "ENetG", "YH2A", "YH2B", "YH2G", "H2total", "Hetotal", "litLith"))])
  otherCats <- otherCats[!duplicated(otherCats), ]
  if(length(colnames(otherCats))>1){
    sumProd <- otherCats %>% left_join(sumDF, by="Sample")
  } else {
    sumProd <- sumDF
  }

  return(sumProd)
}
