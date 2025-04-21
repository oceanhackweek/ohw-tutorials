# Carga el paquete readr
library(readr)

# Lee el archivo CSV
file_path <- "D:/LMOECC-IMARPE/floraciones_algales_clasificacion.csv"
floraciones_algales <- read_csv(file_path)

# Muestra las primeras filas del DataFrame
head(floraciones_algales)
# Carga los paquetes
library(readr)
library(dplyr)
library(ggplot2)


# Convierte el año a factor para el gráfico
floraciones_algales$Año <- as.factor(floraciones_algales$Año)

# Agrupa los datos por año y clasificación, y cuenta las ocurrencias
clasificacion_por_año <- floraciones_algales %>%
  group_by(Año, Clasificación) %>%
  summarise(Frecuencia = n()) %>%
  ungroup()

# Crea el gráfico de la serie de tiempo
ggplot(clasificacion_por_año, aes(x = Año, y = Frecuencia, color = as.factor(Clasificación), group = Clasificación)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Clasificación de Floraciones Algales Nocivas a lo Largo del Tiempo",
    x = "Año",
    y = "Frecuencia",
    color = "Clasificación"
  ) +
  theme_minimal()

#NEURAL NETWORK
# Cargar las librerías
library(readr)
library(dplyr)
library(keras)
library(tensorflow)
library(caret)

# Leer el archivo CSV
file_path <- "D:/LMOECC-IMARPE/floraciones_algales_clasificacion.csv"
data <- read_csv(file_path)

# Convertir el año a factor
data$Año <- as.factor(data$Año)

# Separar los datos en entrenamiento (2020-2022) y prueba (2023)
train_data <- data %>% filter(Año %in% c(2020, 2021, 2022))
test_data <- data %>% filter(Año == 2023)

# Seleccionar las características y la etiqueta
train_x <- train_data %>% select(Estación, Densidad Celular, Temperatura, Profundidad, Corrientes, Salinidad, Viento)
train_y <- train_data$Clasificación

test_x <- test_data %>% select(Estación, Densidad_Celular, Temperatura, Profundidad, Corrientes, Salinidad, Viento)
test_y <- test_data$Clasificación

# Normalizar los datos
preproc <- preProcess(train_x, method = c("center", "scale"))
train_x <- predict(preproc, train_x)
test_x <- predict(preproc, test_x)

# Convertir las etiquetas a factores y luego a categorías
train_y <- to_categorical(as.integer(train_y) - 1)
test_y <- to_categorical(as.integer(test_y) - 1)

# Construir el modelo
model <- keras_model_sequential() %>%
  layer_dense(units = 64, activation = 'relu', input_shape = ncol(train_x)) %>%
  layer_dense(units = 64, activation = 'relu') %>%
  layer_dense(units = 4, activation = 'softmax')

# Compilar el modelo
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy')
)

# Entrenar el modelo
history <- model %>% fit(
  as.matrix(train_x),
  train_y,
  epochs = 30,
  batch_size = 32,
  validation_split = 0.2
)

# Evaluar el modelo
score <- model %>% evaluate(as.matrix(test_x), test_y)
cat('Test loss:', score$loss, '\n')
cat('Test accuracy:', score$accuracy, '\n')

# Hacer predicciones
predictions <- model %>% predict_classes(as.matrix(test_x))

# Convertir predicciones y etiquetas verdaderas de vuelta a sus formas originales
test_y_original <- apply(test_y, 1, which.max) - 1

# Crear una matriz de confusión
confusion_matrix <- table(Predicted = predictions, Actual = test_y_original)
print(confusion_matrix)

# Calcular medidas de rendimiento
precision <- posPredValue(as.factor(predictions), as.factor(test_y_original), positive = "1")
recall <- sensitivity(as.factor(predictions), as.factor(test_y_original), positive = "1")
f1_score <- 2 * ((precision * recall) / (precision + recall))

cat('Precision:', precision, '\n')
cat('Recall:', recall, '\n')
cat('F1 Score:', f1_score, '\n')

