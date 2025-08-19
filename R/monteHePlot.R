#' @title monteHePlot
#'
#' @description
#' Creates a ggplot2 that scales the helium production rate of samples with increasing source rock volume (1km3 to 1000km3)
#'
#' @param modelDF Output dataframe of Monte Carlo model
#' @param ribbon Boolean parameter that controls a geom_ribbon() of the min/max production rate of the samples
#'
#' @examples
#' data("monteDataLithCat")
#' df <- monteProd(lithCat,1000)
#' monteHePlot(df, ribbon=TRUE)
#'
#' List references
#' @export
monteHePlot <- function(modelDF,ribbon=FALSE){

  sumDF <- modelDF %>% group_by(Sample) %>% summarize(minHe=min(Hetotal),
                                                      maxHe=max(Hetotal),
                                                      meanHe=mean(Hetotal),
                                                      sdHe=sd(Hetotal))

  dfProd <- sumDF #make a dataframe for the sample
  dfProd1 <- dfProd #make a dataframe for the sample
  dfProd1$volume <- 1 #for 1 cubic km
  dfProd1$meanHe <- dfProd$meanHe*1e+9
  dfProd1$minHe <- dfProd$minHe*1e+9
  dfProd1$maxHe <- dfProd$maxHe*1e+9

  dfProd1000 <- dfProd #make a dataframe for the sample
  dfProd1000$volume <- 1000 #for 1000 cubic km
  dfProd1000$minHe <- dfProd$minHe*1e+9*1000
  dfProd1000$maxHe <- dfProd$maxHe*1e+9*1000
  dfProd1000$meanHe <- dfProd$meanHe*1e+9*1000

  dfProd <- rbind(dfProd1,dfProd1000)
  print(dfProd)
  xbreaks <- 10^(0:10)
  xminor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))

  ybreaks <- 10^(0:10)
  yminor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))

  if(ribbon==FALSE){
    ggplot(dfProd) +
      geom_line(mapping=aes(x=volume,y=meanHe, color=Sample)) +
      theme_bw() +
      labs(subtitle="",
           x="Source rock volume (km3)",
           y="Yearly He production (mol He / km3 / year)") +
      scale_x_log10() +
      scale_y_continuous(sec.axis=sec_axis(~.*4.0026/1000, name="Produced He mass (kg He / km3 / year)"))
  } else {
    ggplot(dfProd) +
      geom_line(mapping=aes(x=volume,y=meanHe, color=Sample)) +
      geom_ribbon(mapping=aes(x=volume,ymin=minHe,ymax=maxHe, fill=Sample),alpha=0.1) +
      theme_bw() +
      labs(subtitle="",
           x="Source rock volume (km3)",
           y="Yearly He production (mol He / km3 / year)") +
      scale_x_log10() +
      scale_y_continuous(sec.axis=sec_axis(~.*4.0026/1000, name="Produced He mass (kg He / km3 / year)"))
  }

}
