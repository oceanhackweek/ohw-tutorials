# Camille Ross
# 8/29/2024
# Species distribution modeling with R

# Load libraries
library(tidyverse)
library(robis) # retrieves open source species occurrence data
library(biomod2) # species distribution modeling package
library(terra)

# Brief intro to R ----

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

# Useful tip -- pipes
# create some data
x <- c(1, 2, 3, 4, 5, 6) # Create a vector
x <- 1:6 # alternate notation
# Compute mean of x
mean(x)
# Alternative with piping
x |> mean()

# Data frame example with made up data
fake.zoop.data <- data.frame("Genus" = c("Calanus", "Temora", "Centropages"),
                             "Species" = c("finmarchicus", "longicornis", "typicus"),
                             "Abundance" = c(250, 450, 500),
                             "NumAdults" = c(175, 300, 450),
                             "MeanDryWeight" = c(17, 10, 8),
                             "StErrDryWeight" = c(3.4, 1.6, 0.5))

# View data frame
View(fake.zoop.data)

# Accessing data frame columns
fake.zoop.data$Genus

# Accessing multiple columns
fake.zoop.data[c("Genus", "Species")]

# Add a column (base R)
fake.zoop.data$NumJuvenile <- c(75, 150, 50)

# Modifying a column
fake.zoop.data$NumJuvenile <- fake.zoop.data$Abundance - fake.zoop.data$NumAdults

# Add a column to original data frame
fake.zoop.data <- fake.zoop.data |>
  dplyr::mutate(SampMethod = c("Vertical", "Vertical", "Vertical"))

fake.zoop.data

# Filter the data frame
one.genus <- fake.zoop.data |>
  dplyr::filter(Genus == "Calanus" )

one.genus

# Can combine these functions calls in a pipe
one.species <- fake.zoop.data |>
  dplyr::mutate(SampMethod = c("Vertical", "Vertical", "Vertical")) |>
  dplyr::filter(Genus == "Calanus" ) |>
  dplyr::select(Genus, Abundance, SampMethod)

one.species

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

# Species distribution modeling - practival R application ----
# Fetching species data
RightWhale <- robis::occurrence("Eubalaena glacialis", # Right whale
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
  # Sets map bounds to geographic range of the species data
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
  dplyr::select(lon, lat, year)
  
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

# Load environmental predictors ----
# Monthly depth (static), SST (contemporaneous), and CHL (contemporaneous) for summer (jul-sep)
env_dat <- raster::brick("env_stack.tif")

# Add names to raster stack -- were not saved in original tif -- workaround
vars <- c("Depth", "SST", "CHL")
years <- 2005:2015
names(env_dat) <- paste(rep(vars, times = 11), rep(years, each = 3), sep = ".")

env_dat

# Crop to bounding box
env_dat <- crop(env_dat, extent(-75, -60, 35, 46))

# Plot first depth layer
plot(env_dat$Depth.2005)
# Plot first SST layer
plot(env_dat$SST.2005)
# Plot first CHL layer
plot(env_dat$CHL.2005)

# Add presence/absence column to right whale data -- binary
RightWhale <- RightWhale |>
  dplyr::mutate(pa = 1) # we will generate pseudo absences later

# Isolate binary presence/absence data - training years 2005-2010
trainingPA <- RightWhale |>
  dplyr::filter(year < 2011) |>
  dplyr::select(pa)

# Isolate presence/absence coordinates
trainingXY <- RightWhale |>
  dplyr::filter(year < 2011) |>
  dplyr::select(lon, lat)

# Select background points and filter out NAs
# Ideally absence data is available
background <- as.data.frame(env_dat$Depth.2005, xy = TRUE) |> # pull locations from environmental data grid
  dplyr::rename(lon = x, lat = y) |>
  sample_n(30) |>
  dplyr::mutate(pa = 0, year = sample(c(2005, 2011), n(), replace = TRUE)) |>
  dplyr::filter(!is.na(Depth.2005)) |>
  dplyr::select(lon, lat, pa, year)

# Isolate binary presence/absence data - test years 2011-2014
evalPA <- RightWhale |>
  rbind(background) |> # attach background points
  dplyr::filter(year >= 2011 & year < 2015) |>
  dplyr::select(pa)
# Isolate presence/absence coordinates
evalXY <- RightWhale |>
  rbind(background) |> # attach background points
  dplyr::filter(year >= 2011 & year < 2015) |>
  dplyr::select(lon, lat)

# Create climatology of environmental training data for summer 2005-2010
# There is definitely a better way to do this
env_train <- raster::subset(env_dat, c(grep('2005', names(env_dat)),
                                        grep('2007', names(env_dat)),
                                        grep('2008', names(env_dat)),
                                        grep('2009', names(env_dat)),
                                        grep('2010', names(env_dat))))
sst <- raster::subset(env_train, grep('SST', names(env_train))) |>
  mean(na.rm = TRUE)
chl <- raster::subset(env_train, grep('CHL', names(env_train))) |>
  mean(na.rm = TRUE)
depth <- env_train$Depth.2005 # static variable

env_train <- stack(depth, sst, chl)
names(env_train) <- vars

# Create climatology of environmental testing data for July 2011-2014
env_eval <- raster::subset(env_dat, c(grep('2011', names(env_dat)),
                                        grep('2012', names(env_dat)),
                                        grep('2013', names(env_dat)),
                                        grep('2014', names(env_dat))))
sst.eval <- raster::subset(env_eval, grep('SST', names(env_eval))) |>
  mean(na.rm = TRUE)
chl.eval <- raster::subset(env_eval, grep('CHL', names(env_eval))) |>
  mean(na.rm = TRUE)
depth.eval <- env_eval$Depth.2011 # static variable

env_eval <- stack(depth.eval, sst.eval, chl.eval)
names(env_eval) <- vars

# Specify models to run
modelFormulas <- c('GLM', 'GAM', 'ANN')

# Format data for use in Biomod2 modelling function & generate random pseudo-absences ----
biomodData <- BIOMOD_FormatingData(resp.var = trainingPA,
                                   expl.var = env_train,
                                   resp.xy = trainingXY,
                                   eval.resp.var = evalPA,
                                   eval.resp.xy = evalXY,
                                   eval.expl.var = env_eval,
                                   PA.nb.rep = 4, 
                                   PA.nb.absences = 200,
                                   PA.strategy = "random",
                                   resp.name = "RightWhale",
                                   filter.raster = TRUE)

biomodData

# Build the models ----
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

# Extract model evaluations ----
modelEvals <- get_evaluations(obj = modelOut)
modelEvals

# Select TSS
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

# Extract variable importance ----
varImportance <- get_variables_importance(obj = modelOut)

# Plot variable importance
ggplot(data = varImportance, mapping = aes(x = algo, y = var.imp)) +
  geom_boxplot() +
  facet_wrap(~expl.var) +
  labs(x = "Model") +
  theme_bw()
# Response curves ----
# Select highest performing GLMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GLM") |>
  head(5)

# GLM response curves
par(mar=c(3,3,3,3))
bm_PlotResponseCurves(bm.out = modelOut,
                      models.chosen = select_models,
                      new.env = get_formal_data(modelOut, "expl.var"),
                      show.variables = get_formal_data(modelOut, "expl.var.names"),
                      fixed.var = "mean",
                      do.bivariate = FALSE,
                      do.plot = TRUE,
                      do.progress = TRUE)

# Select highest performing GAMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GAM") |>
  head(5)

# GAM response curves
par(mar=c(3,3,3,3))
bm_PlotResponseCurves(bm.out = modelOut,
                      models.chosen = select_models,
                      new.env = get_formal_data(modelOut, "expl.var"),
                      show.variables = get_formal_data(modelOut, "expl.var.names"),
                      fixed.var = "mean",
                      do.bivariate = FALSE,
                      do.plot = TRUE,
                      do.progress = TRUE)

# Select highest performing ANNs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GLM") |>
  head(5)

# ANN response curves
par(mar=c(3,3,3,3))
bm_PlotResponseCurves(bm.out = modelOut,
                      models.chosen = select_models,
                      new.env = get_formal_data(modelOut, "expl.var"),
                      show.variables = get_formal_data(modelOut, "expl.var.names"),
                      fixed.var = "mean",
                      do.bivariate = FALSE,
                      do.plot = TRUE,
                      do.progress = TRUE)

# Project models onto summer 2015 ----

# Project models onto year 2015 (witheld from model)
env_proj <- raster::subset(env_dat, c(grep('2015', names(env_dat))))
names(env_proj) <- vars

# Select highest performing GLMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GLM") |>
  head(5)

glmProj <- BIOMOD_Projection(bm.mod = modelOut,
                             new.env = env_proj,
                             proj.name = "GLM",
                             models.chosen = select_models$name,
                             metric.binary = "TSS",
                             compress = TRUE)

# Select highest performing GAMs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "GAM") |>
  head(5)

gamProj <- BIOMOD_Projection(bm.mod = modelOut,
                             new.env = env_proj,
                             proj.name = "gam",
                             models.chosen = select_models$name,
                             metric.binary = "TSS",
                             compress = TRUE)

# Select highest performing ANNs
select_models <- modelEvals[order(-modelEvals$TSS),] |>
  dplyr::filter(algo == "ANN") |>
  head(5)

annProj <- BIOMOD_Projection(bm.mod = modelOut,
                             new.env = env_proj,
                             proj.name = "ANN",
                             models.chosen = select_models$name,
                             metric.binary = "TSS",
                             compress = TRUE)

plot(glmProj)

plot(gamProj)

plot(annProj)

# Look closer at GAM projection
gamProj

fp <- gamProj@proj.out@link[1]

# Load in as SpatRaster
gamStack <- terra::rast(fp)

# fetch right whale sightings
whales2015 <- RightWhale |>
  dplyr::filter(year == 2015)

# Plot highest performing GAM (slot 1)
plot(gamStack$RightWhale_PA1_RUN1_GAM) 
# Add whale sightings
points(x = whales2015$lon, y = whales2015$lat, cex = 2, pch = 16)


