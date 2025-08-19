#' @title monteProd
#'
#' @description
#' Monte Carlo model of Warr et al (2023) implemented in R.
#'
#' @details
#' The monteProd() function takes a structured dataframe and grabs data from the dataframe by column name. As such, look at example data (lithCat and rockProps) for structure. This outputs a dataframe including all Monte Carlo trials for all input samples. Production rates (H2total, Hetotal) are in rates of mols gas / m3 rock / year following Warr et al. (2023).
#'
#' @param sampDF Structured sample dataframe
#' @param numGen Number of Monte Carlo simulations
#'
#' @examples
#' data("monteDataLithCat")
#' monteProd(lithCat,1000)
#'
#' @export
monteProd <- function(sampDF,numGen){

  #Constants that  are used explicitly (not as parts of distributions) just set here for easier programming
  SA <- 1.5
  SB <- 1.25
  SG <- 1.14

  GH2A <- 1.32
  GH2B <- 0.6
  GH2G <- 0.25
  AConstant <- 6.023E23

  outDF <- NULL

  sampDF$Sample <- as.character(sampDF$Sample)
  data(CRPPData)
  for (i in 1:nrow(sampDF)){
    print(paste(i, "of", nrow(sampDF)))
    samp <- sampDF[i,]
    sampLong <- do.call("rbind", replicate(numGen, samp, simplify = FALSE))

    #perfect distribution function
    rnorm2 <- function(n,mean,sd) { mean+sd*scale(rnorm(n)) }

    rtrunc <- function(n, distr, lower = -Inf, upper = Inf, ...){
      makefun <- function(prefix, FUN, ...){
        txt <- paste(prefix, FUN, "(x, ...)", sep = "")
        function(x, ...) eval(parse(text = txt))
      }
      if(length(n) > 1) n <- length(n)
      pfun <- makefun("p", distr, ...)
      qfun <- makefun("q", distr, ...)
      lo <- pfun(lower, ...)
      up <- pfun(upper, ...)
      u <- runif(n, lo, up)
      qfun(u, ...)
    }

    #A shameful if string to control where we get rock properties from - better than spending more time figuring out the logic here (columns missing or NA)
    if(!"litLith" %in% colnames(samp)){ # if the litLith column does not exist (TRUE) - we have to the listed rock densities and porositites

      rockDen <- as.data.frame(rtrunc(numGen,"norm",lower=samp$rockDenMin,upper=samp$rockDenMax,mean=samp$rockDenMean,sd=samp$rockDenSD)) #rock density
      colnames(rockDen) <- "rockDen"

      porosity <- as.data.frame(rtrunc(numGen,"norm",lower=samp$porMin,upper=samp$porMax,mean=samp$porMean,sd=samp$porSD)) #%>% rename(porosity=x) #porosity
      colnames(porosity) <- "porosity"

    }else if (is.na(samp$litLith)){ #if the litLith exists and is empty - we have to use the listed rock densities and porosities

      rockDen <- as.data.frame(rtrunc(numGen,"norm",lower=samp$rockDenMin,upper=samp$rockDenMax,mean=samp$rockDenMean,sd=samp$rockDenSD)) #rock density
      colnames(rockDen) <- "rockDen"

      porosity <- as.data.frame(rtrunc(numGen,"norm",lower=samp$porMin,upper=samp$porMax,mean=samp$porMean,sd=samp$porSD)) #%>% rename(porosity=x) #porosity
      colnames(porosity) <- "porosity"

    } else { # if the column exsists and is has a value in it, we'll try to find that value in the Enkin database and use those densities and porosities
      data("CRPPData")
      litProps <- CRPPData %>%
        filter(Lithology==samp$litLith )

      rockDen <- as.data.frame(rtrunc(numGen,"norm",lower=litProps$rockDenMin,upper=litProps$rockDenMax,mean=litProps$rockDenMean,sd=litProps$rockDenSD)) #rock density
      colnames(rockDen) <- "rockDen"

      porosity <- as.data.frame(rtrunc(numGen,"norm",lower=litProps$porMin,upper=litProps$porMax,mean=litProps$porMean,sd=litProps$porSD)) #%>% rename(porosity=x) #porosity
      colnames(porosity) <- "porosity"
    }

    fluDen <- as.data.frame(rtrunc(numGen,"norm",lower=samp$fluDenMin,upper=samp$fluDenMax,mean=samp$fluDenMean,sd=samp$fluDenSD)) #Generate the fluid density
    colnames(fluDen) <- "fluDen"

    Uppm <- as.data.frame(rtrunc(numGen,"norm",lower=samp$uMin,upper=samp$uMax,mean=samp$uMean,sd=samp$uSD)) #Generate the uranium distirbution
    colnames(Uppm) <- "Uppm"

    Thppm <- as.data.frame(rtrunc(numGen,"norm",lower=samp$thMin,upper=samp$thMax,mean=samp$thMean,sd=samp$thSD)) #Generate the thorium distribution
    colnames(Thppm) <- "Thppm"

    Kpct <- as.data.frame(rtrunc(numGen,"norm",lower=samp$kMin,upper=samp$kMax,mean=samp$kMean,sd=samp$kSD)) #generate the potassium distribution
    colnames(Kpct) <- "Kpct"

    propDF <- cbind(rockDen,porosity,fluDen,Uppm,Thppm,Kpct) #bind into a dataframe

    #main calculations as one big mutate that calculates per mol/m3/year
    propDF <- propDF %>% mutate(
      sysDen = (rockDen*(1-(porosity/100)))+(fluDen*(porosity/100)),
      W = ((porosity/100)*fluDen)/((1-(porosity/100))*rockDen),
      EKA = Kpct*0, #this is correct, because potassium does not decay through alpha decay
      EKB = Kpct*4.88085E15,
      EKG = Kpct*1.51668E15,
      EThA = Thppm*3.80732E14,
      EThB = Thppm*1.7039E14,
      EThG = Thppm*2.93351E14,
      EUA = Uppm*1.3065E15,
      EUB = Uppm*9.11259E14,
      EUG = Uppm*7.0529E14,
      ENetA = ((EKA+EThA+EUA)*W*SA)/(1+W*SA),
      ENetB = ((EKB+EThB+EUB)*W*SB)/(1+W*SB),
      ENetG = ((EKG+EThG+EUG)*W*SG)/(1+W*SG),
      YH2A = ((ENetA*GH2A)/AConstant)*sysDen*10,
      YH2B = ((ENetB*GH2B)/AConstant)*sysDen*10,
      YH2G = ((ENetG*GH2G)/AConstant)*sysDen*10,
      H2total = YH2A + YH2B + YH2G,  #hydrogen production
      Hetotal = (((3.115E6+1.272E5)*Uppm+7.71E5*Thppm)/AConstant)*sysDen*1E6 #helium production
    )

    outDF <- bind_rows(outDF,cbind(sampLong,propDF))

  }

  return(outDF)
}
