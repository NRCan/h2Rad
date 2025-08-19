#' @title deepTimeProd
#'
#' @description
#' Creates a cumulative He/H2 generation model backwards through geologic time, incorporating radioactive decay of U, Th, and K. Production rates (H2total, Hetotal) are in rates of mols gas / km3 rock / year following Warr et al. (2023).
#'
#' @details
#' This model is programmed in units of millions of years
#'
#' @param monteProdDF Output dataframe of a Monte Carlo model
#' @param startAge Starting age (youngest age) of the model in millions of years (i.e., a value of 50 is fifty million years)
#' @param endAge Ending age (oldest age) of the model in millions of years (i.e., a value of 100 is one hundred million years)
#' @param stepAge Step of the model
#'
#' @examples
#' data("monteDataLithCat")
#' df <- monteProd(lithCat,1000)
#' deepTimeProd(df,1,100,1)
#'
#' @export
deepTimeProd <- function(monteProdDF, startAge, endAge, stepAge){

  #Constants that  are used explicitly (not as parts of distributions) just set here for easier programming
  SA <- 1.5
  SB <- 1.25
  SG <- 1.14

  GH2A <- 1.32
  GH2B <- 0.6
  GH2G <- 0.25
  AConstant <- 6.023E23

  deepTimeProdDF <- NULL
  modelSteps <- seq(from=startAge,to=endAge,by=stepAge)

  #Go into for loop
  for (t in modelSteps){
    print(t)
    stepDF <- monteProdDF %>% mutate(
      UppmT = Uppm * exp((log(2) / 4.468e9) * t),
      ThppmT = Thppm * exp((log(2) / 1.405e10) * t),
      KpctT =  Kpct * (1 + ((exp((log(2) / 1.248e9) * t) - 1) * 0.000117)),
      sysDen = (rockDen*(1-(porosity/100)))+(fluDen*(porosity/100)),
      W = ((porosity/100)*fluDen)/((1-(porosity/100))*rockDen),
      EKA = KpctT*0 ,
      EKB = KpctT*4.88085E15,
      EKG = KpctT*1.51668E15,
      EThA = ThppmT*3.80732E14,
      EThB = ThppmT*1.7039E14,
      EThG = ThppmT*2.93351E14,
      EUA = UppmT*1.3065E15,
      EUB = UppmT*9.11259E14,
      EUG = UppmT*7.0529E14,
      ENetA = ((EKA+EThA+EUA)*W*SA)/(1+W*SA),
      ENetB = ((EKB+EThB+EUB)*W*SB)/(1+W*SB),
      ENetG = ((EKG+EThG+EUG)*W*SG)/(1+W*SG),
      YH2A = ((ENetA*GH2A)/AConstant)*sysDen*10,
      YH2B = ((ENetB*GH2B)/AConstant)*sysDen*10,
      YH2G = ((ENetG*GH2G)/AConstant)*sysDen*10,
      H2total = (YH2A + YH2B + YH2G)*(stepAge*1000000)*1e9,  #hydrogen production. This computes the hydrogen production per km3/year. The "* (stepAge*1000000)" converts the function input of the model step (say a model step representing 2 M.y.) representing 2,000,000. This also takes finer model steps (e.g., 0.5 M.y.) and converts them appropriately
      Hetotal = ((((3.115E6+1.272E5)*UppmT+7.71E5*ThppmT)/AConstant)*sysDen*1E6)*(stepAge*1000000)*1e9,
      time=t
    )
    stepDF <- stepDF %>%
      group_by(Sample) %>%
      summarize(H2MinProd=min(H2total),
                H2MeanProd=mean(H2total),
                H2MaxProd=max(H2total),
                HeMinProd=min(Hetotal),
                HeMeanProd=mean(Hetotal),
                HeMaxProd=max(Hetotal),
                time=t,
                step=stepAge)

    deepTimeProdDF <- rbind(deepTimeProdDF,stepDF)
  }



  return(deepTimeProdDF)
}
