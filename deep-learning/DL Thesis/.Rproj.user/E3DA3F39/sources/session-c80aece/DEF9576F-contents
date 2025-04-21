setwd("C:/Users/EQUIPO/Documents/GitHub/ohw-tutorials/deep-learning")
#Sys.setenv(TF_ENABLE_ONEDNN_OPTS=0)
library(tensorflow)
library(keras)
library(dplyr)
library(keras3)
# Cargar la funciones auxiliares
source("tutorial_functions.R")
# Leer archivo csv
raw_data <- readr::read_csv("tutorial_data_test.csv") 
head(raw_data)
# Transformación logaritmica
raw_data <- raw_data %>%
  log_inputs(vars = c("t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"))
#Generate images from data
image_list <- make_image_list(raw_data,
                              tox_levels =     c(0,10,30,80),
                              forecast_steps = 1,
                              n_steps =        2,
                              minimum_gap =    4,
                              maximum_gap =    10,
                              toxins =         c("t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"),
                              environmentals = c("sst_cum"))
#Splits image_list by year for grouping into train/test data
years <- sapply(image_list, function(x) {return(x$year)})
#image_list <- split(image_list,as.factor(years))
image_list <- split(image_list, years)
#configuration
YEARS_TRAINING <-   c("2014", "2016", "2017")
YEARS_TESTING <-    "2015"
#Make a training set
train <- pool_images_and_labels(image_list[YEARS_TRAINING], num_classes = 4)
#Make a test set
test <- pool_images_and_labels(image_list[YEARS_TESTING], num_classes = 4)

save(data, file = "data.Rdata")

str(train)
head(train$labels)
#-----
model <- keras::keras_model_sequential() %>% 
  keras::layer_dense(units=64, 
                     activation = "relu", 
                     input_shape = dim(train$image)[2],
                     name = "input_layer") %>%
  keras::layer_dropout(rate = 0.4,
                       name = "dropout_1") %>% 
  keras::layer_dense(units=32, 
                     activation = "relu",
                     name = "hidden_1") %>% 
  keras::layer_dropout(rate=0.3,
                       name = "dropout_2") %>% 
  keras::layer_dense(units=16, 
                     activation = "relu",
                     name = "hidden_2") %>% 
  keras::layer_dropout(rate=0.2,
                       name = "dropout_3") %>%
  keras::layer_dense(units = 4, 
                     activation = "softmax",
                     name = "output")

summary(model)

str(train)
head(train$labels)

model %>% keras::compile(optimizer =  "adam",
                         loss =       "categorical_crossentropy", 
                         metrics =    "categorical_accuracy")

history <- model %>% 
  keras::fit(x = train$image,
             y = train$labels,
             batch_size = 128,
             epochs = 32,
             verbose=1,
             validation_split = 0.2,
             shuffle = TRUE)

plot(history)

metrics <- model %>% 
  keras::evaluate(x = test$image,
                  y = test$labels)

predictions <- model %>% 
  keras::predict_classes(test$image)

predicted_probs <- model %>% 
  keras::predict_proba(test$image)

metrics

results <- dplyr::tibble(location = test$locations,
                         date = as.Date(as.numeric(test$dates), origin = as.Date("1970-01-01")),
                         actual_classification = test$classifications,
                         predicted_classification = predictions) %>% 
  dplyr::mutate(prob_0 = predicted_probs[,1]*100,
                prob_1 = predicted_probs[,2]*100,
                prob_2 = predicted_probs[,3]*100,
                prob_3 = predicted_probs[,4]*100)

head(results)

num_levels <- 4
levels <- seq(from=0, to=(num_levels-1))

cm <- as.data.frame(table(predicted = factor(predictions, levels), actual = factor(test$classifications, levels)))

confusion_matrix <- ggplot2::ggplot(data = cm,
                                    mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
  ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue") +
  ggplot2::labs(x = "Predicted Classifications", 
                y = "Actual Classifications", 
                title=paste("Confusion Matrix -", YEARS_TESTING, "Toxin Testing Season Hindcast",sep=" "),
                subtitle=paste("Loss:", round(metrics[1], 3), "Accuracy:", round(metrics[2], 3), sep=" "),
                caption=paste(Sys.Date())) +
  ggplot2::theme_linedraw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                 axis.title= ggplot2::element_text(size=14,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none") 

confusion_matrix