#' @title Example of structured dataframe for radiolysis Monte Carlo simulation with lithologic categories
#'
#' @description This is an example dataframe structured for the monteProd() function of Radiolysis that uses a lithologic category from the Canadian Rock Physical Property Database (CRPPData) in lieu of physical rock properties (rock density and porosity).
#'
#' \itemize{
#'   \item Sample. Sample name
#'   \item litLith. Lithology from CRPPData
#'   \item fluDenMin. Minimum value of fluid density (g/cm3) distribution used in simulation
#'   \item fluDenMax. Maximum value of fluid density (g/cm3) distribution used in simulation
#'   \item fluDenMean. Mean value of fluid density (g/cm3) distribution used in simulation
#'   \item fluDenSD. Standard deviation of fluid density distribution (g/cm3) used in simulation
#'   \item uMin. Minimum value of uranium (ppm) distribution used in simulation
#'   \item uMax. Maximum value of uranium (ppm) distribution used in simulation
#'   \item uMean. Mean value of uranium (ppm) distribution used in simulation
#'   \item uSD. Standard deviation of uranium (ppm) distribution used in simulation
#'   \item thMin. Minimum value of thorium (ppm) distribution used in simulation
#'   \item thMax. Maximum value of thorium (ppm) distribution used in simulation
#'   \item thMean. Mean value of thorium (ppm) distribution used in simulation
#'   \item thSD. Standard deviation of thorium (ppm) distribution used in simulation
#'   \item kMin. Minimum value of potassium (WT%) distribution used in simulation
#'   \item kMax. Maximum value of potassium (WT%) distribution used in simulation
#'   \item kMean. Mean value of potassium (WT%) distribution used in simulation
#'   \item kSD. Standard deviation of potassium (WT%) distribution used in simulation
#' }
#'
#' @docType data
#' @name lithCat
#' @usage data(monteDataLithCat)
#' @references Radiolysis.
#' @format A data frame formated for
#' @keywords datasets
NULL
