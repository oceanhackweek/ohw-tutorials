# Camille Ross
# 8/29/2024
# Ocean Hack Week R Application

# Load libraries
library(tidyverse)
library(robis) # retrieves open source species occurrence data
library(biomod2) # species distribution modeling package

# Basic R ----
# Assignment operators
x <- 2 # preferred
x = 2 # also works

# Math operations
x * 2
x^2 == x**2
x/10

1e+12

log(pi)
log10(pi)

# Data frame example with made up data
fake.zoop.data <- data.frame("Genus" = c("Calanus", "Temora", "Centropages"),
                           "Species" = c("finmarchicus", "longicornis", "typicus"),
                           "Abundance" = c(250, 450, 500),
                           "NumAdults" = c(175, 300, 450),
                           "MeanDryWeight" = c(17, 10, 8),
                           "StErrDryWeight" = c(3.4, 1.6, 0.5))


# Plot the data
plot(x = fake.zoop.data$Abundance, y = fake.zoop.data$MeanDryWeight)

# A better way to plot the data
ggplot(data = fake.zoop.data, mapping = aes(x = Abundance, y = MeanDryWeight)) +
  geom_point()

# Alternative notation
ggplot() +
  geom_point(data = fake.zoop.data, mapping = aes(x = Abundance, y = MeanDryWeight))

# Add error bars
ggplot(data = fake.zoop.data, mapping = aes(x = Abundance, y = MeanDryWeight)) +
  geom_point() + 
  geom_errorbar(mapping = aes(ymin = MeanDryWeight-StErrDryWeight, ymax = MeanDryWeight+StErrDryWeight))

# Improve plot aesthetics
ggplot(data = fake.zoop.data, mapping = aes(x = Abundance, y = MeanDryWeight)) +
  geom_point() + 
  geom_errorbar(mapping = aes(ymin = MeanDryWeight-StErrDryWeight, ymax = MeanDryWeight+StErrDryWeight)) +
  labs(x = bquote("Abundance (individuals"~m^{-3}*")"), y = "Mean Dry Weight (mg)") +
  theme_bw() # many theme options

# Practical R application - Species distribution modeling ----
# Fetching species data
RightWhale <- robis::occurrence("Eubalaena glacialis", # North Atlantic right whale
                                startdate = as.Date("2005-01-01"),
                                enddate = as.Date("2015-12-31"))

# Load world map data 
worldmap <- ggplot2::map_data("world")

# Plot occurrences on world map
ggplot2::ggplot(data = RightWhale, mapping = aes(x = decimalLongitude, y = decimalLatitude)) +
  # Add occurrence data
  geom_point() +
  # Add map data
  geom_polygon(data = worldmap, aes(long, lat, group = group), fill = NA, colour = "gray43") +
  coord_quickmap(xlim = c(round(min(RightWhale$decimalLongitude)), 
                          round(max(RightWhale$decimalLongitude))), 
                 ylim = c(round(min(RightWhale$decimalLatitude)), 
                          round(max(RightWhale$decimalLatitude))),
                 expand = TRUE) +
  # Clean up theme
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Define bounding box for data
BB <- c(-75, -60, 35, 46)

# Crop data to bounding box
RightWhale <- RightWhale |>
  # Shorten names
  dplyr::rename(lon = decimalLongitude,
                lat = decimalLatitude) |>
  dplyr::mutate(year = as.numeric(year),
                month = as.numeric(month)) |>
  # Filter July, Aug, Sep
  dplyr::filter(month %in% 7:9) |>
  # Filter to bounding box
  dplyr::filter(lon >= BB[1] & lon <= BB[2] &
                  lat >= BB[3] & lat <= BB[4]) |>
  # Select relevant columns
  dplyr::select(lon, lat, year, month)
  
# Plot again
ggplot2::ggplot(data = RightWhale, mapping = aes(x = lon, y = lat)) +
  # Add occurrence data
  geom_point() +
  # Add map data
  geom_polygon(data = worldmap, aes(long, lat, group = group), fill = NA, colour = "gray43") +
  coord_quickmap(xlim = c(BB[1], BB[2]), 
                 ylim = c(BB[3], BB[4]),
                 expand = TRUE) +
  # Clean up theme
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Load environmental predictors
env_dat <- raster::brick("env_stack.tif")

# Add names to raster stack
vars <- c("Depth", "SST", "CHL")
months <- 7:9
years <- 2005:2015
names(env_dat) <- paste(rep(vars, times = 33), rep(months, each = 3, times = 11), rep(years, each = 9), sep = ".")

# Crop to bounding box
env_dat <- crop(env_dat, extent(-75, -60, 35, 46))

# Plot first layer
plot(env_dat$Depth.7.2005)

# Add presence/absence column to right whale data
RightWhale <- RightWhale |>
  dplyr::mutate(pa = 1)

# Select background points and filter out NAs
background <- as.data.frame(env_dat$Depth.7.2005, xy = TRUE) |> # pull locations from environmental data grid
  dplyr::rename(lon = x, lat = y) |>
  sample_n(500) |>
  dplyr::mutate(pa = 0, year = 2005) |>
  dplyr::filter(!is.na(Depth.7.2005)) |>
  dplyr::select(lon, lat, pa, year)

# Plot occurence data w/ background points
ggplot2::ggplot(data = RightWhale, mapping = aes(x = lon, y = lat)) +
  # Add occurrence data
  geom_point(color = "red") +
  # Add background points
  geom_point(data = background, mapping = aes(x = lon, y = lat), color = "black") +
  # Add map data
  geom_polygon(data = worldmap, aes(long, lat, group = group), fill = NA, colour = "gray43") +
  coord_quickmap(xlim = c(BB[1], BB[2]), 
                 ylim = c(BB[3], BB[4]),
                 expand = TRUE) +
  # Clean up theme
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Bind occurrence and background data
RightWhale.training <- rbind(RightWhale, background)

# Isolate binary presence/absence data
trainingPA <- RightWhale.training |>
  dplyr::filter(year < 2011) |>
  dplyr::select(pa)
# Isolate presence/absence coordinates
trainingXY <- RightWhale.training |>
  dplyr::filter(year < 2011) |>
  dplyr::select(lon, lat)

# Isolate binary presence/absence data
evalPA <- RightWhale.training |>
  dplyr::filter(year < 2011) |>
  dplyr::select(pa)
# Isolate presence/absence coordinates
evalXY <- RightWhale.training |>
  dplyr::filter(year < 2011) |>
  dplyr::select(lon, lat)

# Create climatology of environmental training data for July through September for 2005-2010
env_summer <- raster::subset(env_dat, c(grep('2005', names(env_dat)),
                                        grep('2005', names(env_dat)),
                                        grep('2007', names(env_dat)),
                                        grep('2008', names(env_dat)),
                                        grep('2009', names(env_dat)),
                                        grep('2010', names(env_dat))))
sst <- raster::subset(env_summer, grep('SST', names(env_summer))) |>
  mean(na.rm = TRUE)
chl <- raster::subset(env_summer, grep('CHL', names(env_summer))) |>
  mean(na.rm = TRUE)
depth <- env_dat$Depth.7.2005 # static variable

env_clim <- stack(depth, sst, chl)
names(env_clim) <- vars

# Create climatology of environmental testing data for July through September for 2011-2015
env_summer.eval <- raster::subset(env_dat, c(grep('2011', names(env_dat)),
                                        grep('2012', names(env_dat)),
                                        grep('2013', names(env_dat)),
                                        grep('2014', names(env_dat)),
                                        grep('2015', names(env_dat))))
sst.eval <- raster::subset(env_summer, grep('SST', names(env_summer))) |>
  mean(na.rm = TRUE)
chl.eval <- raster::subset(env_summer, grep('CHL', names(env_summer))) |>
  mean(na.rm = TRUE)
depth.eval <- env_dat$Depth.7.2005 # static variable

env_clim.eval <- stack(depth.eval, sst.eval, chl.eval)
names(env_clim.eval) <- vars

# Specify models to run
modelFormulas <- c("GLM", "GAM", "RF")

# Set aside random 15% of the data for evaluation
#idx <- sample(1:nrow(trainingPA), round(0.15*nrow(trainingPA)), replace=FALSE)

# Format data for use in Biomod2 modelling function
biomodData <- BIOMOD_FormatingData(resp.var = trainingPA[-idx,],
                                   expl.var = env_clim,
                                   resp.xy = trainingXY[-idx,],
                                   eval.resp.var = trainingPA[idx,],
                                   eval.expl.var = env_clim,
                                   eval.resp.xy = trainingXY[idx,],
                                   resp.name = "RightWhale",
                                   filter.raster = TRUE)

# Build the models
modelOut <- BIOMOD_Modeling(bm.format = biomodData,
                            modeling.id = "RightWhale",
                            models = c("GLM", "GAM", "ANN"),
                            CV.nb.rep = 10, # 10-fold cross validation
                            data.split.perc = 70, # 70%/30% training/testing data split
                            prevalence = 0.5,
                            var.import = 5,
                            metric.eval = c('ROC', 'TSS', 'KAPPA'),
                            scale.models = FALSE,
                            do.progress = TRUE)



# Extract model evaluations
modelEvals <- get_evaluations(obj = modelOut)
#View(modelEvals)

# Simplify
modelEvals <- modelEvals |>
  dplyr::filter(metric.eval == "TSS") |>
  dplyr::group_by(algo) |>
  dplyr::reframe(TSS = evaluation,
                 name = full.name)

# Plot TSS
ggplot(data = modelEvals, mapping = aes(x = algo, y = TSS)) +
  geom_boxplot() +
  labs(x = "Model") +
  theme_bw()

# Extract variable importance
varImportance <- get_variables_importance(obj = modelOut)

# Plot variable importance
ggplot(data = varImportance, mapping = aes(x = algo, y = var.imp)) +
  geom_boxplot() +
  facet_wrap(~expl.var) +
  labs(x = "Model") +
  theme_bw()

# Plot response curves
par(mar=c(3,3,3,3))
bm_PlotResponseCurves(bm.out = modelOut,
                      models.chosen = "all",
                      new.env = get_formal_data(modelOut, "expl.var"),
                      show.variables = get_formal_data(modelOut, "expl.var.names"),
                      fixed.var = "mean",
                      do.bivariate = FALSE,
                      do.plot = TRUE,
                      do.progress = TRUE)

# Project models

# Create climatology of environmental data for 2010
env_2010 <- raster::subset(env_dat, grep('2010', names(env_dat)))
sst <- raster::subset(env_2010, grep('SST', names(env_2010))) |>
  mean(na.rm = TRUE)
chl <- raster::subset(env_2010, grep('CHL', names(env_2010))) |>
  mean(na.rm = TRUE)
depth <- env_dat$Depth.1.2010 # static variable

env_clim <- stack(depth, sst, chl)
names(env_clim) <- vars

# Select highest performing GLMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GLM") |>
  head(5)

glmProj <- BIOMOD_Projection(bm.mod = modelOut,
                            new.env = env_clim,
                            proj.name = "GLM",
                            models.chosen = select_models$name,
                            metric.binary = "TSS",
                            compress = TRUE)


# Select highest performing GAMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GAM") |>
  head(5)

gamProj <- BIOMOD_Projection(bm.mod = modelOut,
                             new.env = env_clim,
                             proj.name = "gam",
                             models.chosen = select_models$name,
                             metric.binary = "TSS",
                             compress = TRUE)


# Select highest performing ANNs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "ANN") |>
  head(5)

annProj <- BIOMOD_Projection(bm.mod = modelOut,
                             new.env = env_clim,
                             proj.name = "ANN",
                             models.chosen = select_models$name,
                             metric.binary = "TSS",
                             compress = TRUE)

# Plot projections
plot(glmProj)

plot(gamProj)

plot(annProj)











