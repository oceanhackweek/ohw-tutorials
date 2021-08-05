#' Set classification values 
#' 
#' @param v vector of numbers (x$total_toxicity)
#' @param lut ordered vector of toxicity levels (tox_levels)
#' @param na_value value to replace missing values in v
#' @return ix vector closure codes
#' 
#' @export
recode_classification <- function(v, 
                                  lut = c(0,10,30,80), 
                                  na_value = 0){
  na <- is.na(v)
  v[na] <- na_value
  
  ix <- findInterval(v, lut) -1
  
  return(ix)
} 


#' Takes toxin and environmental input columns and normalizes to rance 0-1
#' 
#' @param x tibble of raw data
#' @param toxins toxins in raw data
#' @param environmentals environmental variables
#' @return tibble of normalized input columns 
#' 
#' @export
normalize_input <- function(x, toxins, environmentals) {
  
  image_cols <- x %>% 
    dplyr::select(dplyr::all_of(c(toxins, environmentals)))
  
  other_cols <- x %>% 
    dplyr::select(!dplyr::all_of(c(toxins, environmentals)))
  
  scaling_factors <- list(min  = apply(image_cols, 2, min, na.rm=TRUE), 
                          max  = apply(image_cols, 2, max, na.rm=TRUE), 
                          mean = apply(image_cols, 2, mean, na.rm=TRUE), 
                          std  = apply(image_cols, 2, sd, na.rm=TRUE))
  
  scaled_image_cols <- sapply(names(image_cols), function(name) {(image_cols[[name]] - scaling_factors$min[name])/(scaling_factors$max[name] - scaling_factors$min[name])}, simplify=FALSE) %>% 
    dplyr::bind_cols()
  
  scaled_data <- dplyr::bind_cols(other_cols, scaled_image_cols)
  
  return(scaled_data)
}


#' For a given station and year, find how many batches(images) can be made
#' 
#' @param nx number of samples for that year and station
#' @param steps number of weeks in the image
#' @return nbatches number of batches that can be made for a given year and station
#' 
#' @export
n_batches <- function(nx, 
                      steps) {
  nbatches <- nx - steps + 1
  
  return(nbatches)
}


#' For a given station and year, find the indices of each batch (image) that can be made from the subset
#' 
#' @param nbatches number of batches that can be made for a given year and station
#' @param steps number of weeks in the image
#' @return batches 
#' 
#' @export
compute_batches <- function(nbatches, 
                            steps) {
  steps <- 1:steps 
  batches <- lapply(1:nbatches, function(n){steps + n - 1})
  
  return(batches)
}


#' Checks gap_days column to filter for only
#' 
#' @param x gap days column from raw data
#' @param minimum_gap gaps allowed into an image must be greater than
#' @param maximum_gap gaps allowed into an image must be less than
#' @return logical for each row in data - TRUE if gap meets gap criteria, FALSE if not
#' 
#' @export
check_gap <- function(x, minimum_gap, maximum_gap) {
  
  #gap_status <- lapply(x, function(gap) {if (minimum_gap < gap && gap < maximum_gap) {return(TRUE)} else {return(FALSE)}} )
  gap_status <- x >= minimum_gap & x <= maximum_gap
  
  return(gap_status)
}

#' Function to log a list of inputs
#' 
#' @param data raw input data
#' @param vars a list of variables to transform
#' @return same data as input but with log transformed variables
#' 
#' @export
log_inputs <- function(data, 
                       vars = c("gtx4", "gtx1", "dcgtx3", "gtx5", "dcgtx2", "gtx3", "gtx2", "neo", "dcstx", "stx", "c1", "c2",
                                "prcp_wiscasset_airport", "prcp_east_surry", "old_stream", "narraguagus", "otter_creek", "ducktrap", "androscoggin",
                                "prcp_portland_jetport","mousam", "branch_brook", "st_croix_baring")) {
  
  log_transform <- function(var) {
    r <- log10(var+1)
    return(r)
  }
  
  logged_data <- data %>% 
    dplyr::mutate_at(vars, log_transform)
  
  return(logged_data)
}

#' Takes raw input data, filters for image criteria and creates images with dimensions (n_steps + forecast steps) x length(toxins + environmentals)
#' 
#' @param raw_data database with toxin measurements with their date sampled, location, shellfish species and additional environmental data
#' @param tox_levels toxin level categories used for classifying total toxicity
#' @param forecast_steps the number of weeks ahead of the image the forecast is made for
#' @param n_steps the number of weeks of samples in an image
#' @param minimum_gap the smallest gap between samples allowed into an image
#' @param maximum_gap the largest gap between samples allowed into an image
#' @param toxins list of individual paralytic toxin names (12) for toxin columns
#' @param environmentals environmental variables
#' @return each list is an image along with its associated data (location_id, date, etc.)
#' \itemize{
#' \item{status logical if the image passes the image gap criteria (gap >= minimum_gap & gap <= maximum_gap)}
#' \item{year the year the image is from}
#' \item{location_id the sampling station id}
#' \item{toxixty the total toxicity used to regress on instead of classify a binned toxicity}
#' \item{classification the classification (0:num_classes) of the final row in the image}
#' \item{date the date of the final row in the image (the forecast is for forecast_steps ahead of this date)}
#' \item{image a 2 dimensional array with the dimensions (n_steps + forecast steps) x length(toxins + environmentals)}
#' }
#' 
#' @export
make_image_list <- function(raw_data, tox_levels, forecast_steps, n_steps, minimum_gap, maximum_gap, toxins, environmentals) {
  
  normalized_data <- raw_data %>% 
    dplyr::mutate(classification = recode_classification(.data$total_toxicity, tox_levels),
                  meets_gap = check_gap(.data$gap_days, minimum_gap, maximum_gap)) %>% 
    normalize_input(toxins, environmentals)
  
  find_images <- function(tbl, key, forecast_steps, n_steps, minimum_gap, maximum_gap, toxins, environmentals) {
    
    make_images <- function(batch, tbl, forecast_steps, n_steps, minimum_gap, maximum_gap, toxins, environmentals) {
      
      image_batch <- tbl %>% dplyr::slice(batch)
      
      if (any(image_batch$meets_gap[2:(n_steps+forecast_steps)] == FALSE)) {
        z <- list(status=FALSE)
      } else {
        image <- as.matrix(dplyr::ungroup(image_batch) %>% 
                             dplyr::select(dplyr::all_of(c(toxins, environmentals))))
        
        if (image_batch$id[n_steps+forecast_steps] == "FORECAST_WEEK") {
          z <- list(status=          TRUE,
                    year =           "FORECAST_IMAGE",
                    location_id =    image_batch$location_id[1],
                    classification = image_batch$classification[n_steps+forecast_steps],
                    toxicity =       image_batch$total_toxicity[n_steps+forecast_steps],
                    date =           image_batch$date[n_steps],
                    image =          image[1:n_steps,])
        } else {
          z <- list(status=          TRUE,
                    year =           image_batch$year[1],
                    location_id =    image_batch$location_id[1],
                    classification = image_batch$classification[n_steps+forecast_steps],
                    toxicity =       image_batch$total_toxicity[n_steps+forecast_steps],
                    date =           image_batch$date[n_steps],
                    image =          image[1:n_steps,])
          
        }
        
        return(z)
      }
    }
    
    if (nrow(tbl) < (n_steps+forecast_steps)) {
      return(NULL)
    }
    
    nbatches <- n_batches(nrow(tbl), (n_steps+forecast_steps))
    batches <- compute_batches(nbatches, (n_steps+forecast_steps))
    
    xx <- lapply(batches, make_images, tbl, forecast_steps, n_steps, minimum_gap, maximum_gap, toxins, environmentals)
    gap_verified <- sapply(xx, function(x){return(x$status)})
    
    xx <- xx[gap_verified]
    
    return(xx)
  }
  
  image_list <- normalized_data %>%
    dplyr::group_by(.data$location_id, .data$year) %>%
    dplyr::arrange(date) %>% 
    dplyr::group_map(find_images, forecast_steps, n_steps, minimum_gap, maximum_gap, toxins, environmentals, .keep=TRUE) %>% 
    unlist(recursive = FALSE)
  
  return(image_list)
  
}


#' Crates image and labels for input into neural net
#' Image takes all images in psp_lst and stretches them into an array
#' Labels takes classifications and categorizes them for nn input
#' 
#' @param image_list_subset subset of image list from make_image_list() for either training or testing data
#' @param num_classes the number of toxicity classification categories 
#' @param missing_value value to replace na with
#' @param scaling_factors null if training data; training data scaling factors are passed to scale testing data
#' @param scaling selected method to scale input data
#' @param downsample logical indicating whether or not to balance the frequency of each class in the training images
#' @param upsample logical to call a function that balances class distribution by upsampling rare classes
#' @return list containing the formatted images and their labels as keras model input, and additional data
#' \itemize{
#' \item{labels}
#' \item{image a 2 dimensional array where each row is an image and the columns are toxins and environmentals from each week}
#' \item{classifications the classification of each image}
#' \item{locations the sampling station of each image}
#' \item{dates the date of the final week of each image}
#' \item{scaling_factors}
#' }
#' 
#' @export
pool_images_and_labels <- function(image_list_subset, 
                                   num_classes = 4, 
                                   missing_value = 0.5, 
                                   scaling_factors = NULL, 
                                   scaling = c("normalize", "input_scale")[2],
                                   downsample=FALSE,
                                   upsample=FALSE) {
  
  xx <- unlist(image_list_subset, recursive = FALSE) 
  
  if (upsample == TRUE) {
    xx <- xx %>% 
      upsample()
  }
  
  if (downsample == TRUE) {
    xx <- xx %>% 
      balance_classes() %>% 
      sample()
  } else{
    xx <- xx %>% 
      sample()
  }
  
  dim_image <- dim(xx[[1]]$image)
  
  images <- lapply(xx, function(x){return(x$image)})
  
  # Replace any NA values with specified missing value
  # @param x 
  # @param missing_value to replace na toxin levels with
  # @return x
  replace_na <- function(x, missing_value = -1) {
    x[is.na(x)] <- missing_value
    return(x)
  }
  
  image <- abind::abind(images, along = 3) %>% 
    aperm(c(3, 1, 2)) %>% 
    keras::array_reshape(c(length(xx), prod(dim_image)))
  
  image <- image %>% 
    replace_na(missing_value = missing_value)
  
  labels <- sapply(xx, function(x){return(x$classification)}) %>% 
    keras::to_categorical(num_classes = num_classes)
  
  classifications <- sapply(xx, function(x){return(x$classification)})
  attr(classifications, "names") <- NULL
  
  locations <- sapply(xx, function(x){return(x$location_id)})
  attr(locations, "names") <- NULL
  
  dates <- sapply(xx, function(x){return(x$date)})
  attr(dates, "names") <- NULL
  
  toxicity = sapply(xx, function(x){x$toxicity})
  attr(toxicity, "names") <- NULL
  
  r <- list(labels = labels, 
            image = image, 
            classifications = classifications,
            toxicity = toxicity,
            locations = locations,
            dates = dates,
            scaling_factors = scaling_factors)
  
  return(r)
  
} 

