#' @title monteH2Plot
#'
#' @description
#' Creates a ggplot2 that scales the hydrogen production rate of samples with increasing source rock volume (1km3 to 1000km3)
#'
#' @param modelDF Output dataframe of Monte Carlo model
#' @param ribbon Boolean parameter that controls a geom_ribbon() of the min/max production rate of the samples
#'
#' @examples
#' data("monteDataLithCat")
#' df <- monteProd(lithCat,1000)
#' monteH2Plot(df, ribbon=TRUE)
#'
#' List references
#' @export
monteH2Plot <- function(modelDF, ribbon=FALSE){

  sumDF <- modelDF %>% group_by(Sample) %>% summarize(minH2=min(H2total),
                                                      maxH2=max(H2total),
                                                      meanH2=mean(H2total),
                                                      sdH2=sd(H2total))

  dfProd <- sumDF #make a dataframe for the sample
  dfProd1 <- dfProd #make a dataframe for the sample
  dfProd1$volume <- 1 #for 1 cubic km
  dfProd1$meanH2 <- dfProd$meanH2*1e+9
  dfProd1$minH2 <- dfProd$minH2*1e+9
  dfProd1$maxH2 <- dfProd$maxH2*1e+9

  dfProd1000 <- dfProd #make a dataframe for the sample
  dfProd1000$volume <- 1000 #for 1000 cubic km
  dfProd1000$minH2 <- dfProd$minH2*1e+9*1000
  dfProd1000$maxH2 <- dfProd$maxH2*1e+9*1000
  dfProd1000$meanH2 <- dfProd$meanH2*1e+9*1000

  dfProd <- rbind(dfProd1,dfProd1000)
  print(dfProd)
  xbreaks <- 10^(0:10)
  xminor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))

  ybreaks <- 10^(0:10)
  yminor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))
  if(ribbon==FALSE){
    ggplot(dfProd) +
      geom_line(mapping=aes(x=volume,y=meanH2, color=Sample)) +
      theme_bw() +
      xlab("Source rock volume (km3)") +
      ylab("Yearly H2 production (mol H2 / km3 / year)") +
      scale_x_log10() +
      scale_y_continuous(sec.axis=sec_axis(~.*2.016/1000, name="Produced H2 mass (kg H2 / km3 / year)"))
  } else {
    ggplot(dfProd) +
      geom_line(mapping=aes(x=volume,y=meanH2, color=Sample)) +
      geom_ribbon(mapping=aes(x=volume,ymin=minH2,ymax=maxH2, fill=Sample),alpha=0.1) +
      theme_bw() +
      xlab("Source rock volume (km3)") +
      ylab("Yearly H2 production (mol H2 / km3 / year)") +
      scale_x_log10() +
      scale_y_continuous(sec.axis=sec_axis(~.*2.016/1000, name="Produced H2 mass (kg H2 / km3 / year)"))
  }

}
