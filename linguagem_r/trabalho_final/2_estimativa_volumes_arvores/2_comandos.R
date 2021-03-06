### ----------------------------------------------------------------------------
###
### UNIVERSIDADE FEDERAL DO PARANA
### Especializacao em Inteligencia Artificial Aplicada
### IAA004 - Linguagem R
### Luiza Ruivo Marinho
###
### ----------------------------------------------------------------------------

### ----------------------------------------------------------------------------
### 2 - Estimativa de Volumes de �rvores
###

# Adiciona o pacote caret pra fazer o particionamento dos dados:
install.packages("caret")
library("caret")

## Carregar o arquivo Volumes.csv (http://www.razer.net.br/datasets/Volumes.csv):
getwd()
dataset <- read.csv("/Projects/ia_ufpr/linguagem_r/trabalho_final/2_estimativa_volumes_arvores/Volumes.csv", 
                    header = TRUE, sep = ';', dec = ',')

# Visualizar  os dados:
head(dataset)
#     NR    DAP    HT       HP      VOL
# 1   1     34.0   27.00    1.80    0.8971441
# 2   2     41.5   27.95    2.75    1.6204441
# 3   3     29.6   26.35    1.15    0.8008181
# 4   4     34.3   27.15    1.95    1.0791682
# 5   5     34.5   26.20    1.00    0.9801112
# 6   6     29.9   27.10    1.90    0.9067022

## Eliminar a coluna NR, que s� apresenta um n�mero sequencial:
dataset <- dataset[-1]
head(dataset)
#     DAP     HT        HP      VOL
# 1   34.0    27.00     1.80    0.8971441
# 2   41.5    27.95     2.75    1.6204441
# 3   29.6    26.35     1.15    0.8008181
# 4   34.3    27.15     1.95    1.0791682
# 5   34.5    26.20     1.00    0.9801112
# 6   29.9    27.10     1.90    0.9067022

## Criar parti��o de dados: treinamento 80%, teste 20%:
indexes <- createDataPartition(dataset$VOL, p = 0.80, list = FALSE)

## Usando o pacote "caret", treinar os modelos: 
## Random Forest (rf), SVM (svmRadial), 
## Redes Neurais (neuralnet) e o modelo alom�trico de SPURR:
training <- dataset[indexes,]
test <- dataset[-indexes,]

set.seed(0)
rf <- train(VOL ~., data = training, method = 'rf',
            trControl = trainControl('cv', number = 10), preProcess = c('center', 'scale')) # RandomForest
svm <- train(VOL ~., data = training, method = 'svmRadial',
             trControl = trainControl('cv', number = 10), preProcess = c('center', 'scale')) # SVM
nn <- train(VOL ~ ., data = training, method = 'neuralnet', linear.output = TRUE, threshold = 0.1,
            trControl = trainControl('cv', number = 10), preProcess = c('center', 'scale')) # RNA

## O modelo alom�trico � dado por: Volume = b0 + b1 * dap2 * H:
alom <- nls(VOL ~ b0 + b1 * DAP * DAP * HT, training, start = list(b0 = 0.5, b1 = 0.5)) # SPURR

## Predi��es nos dados de teste:
predict.rf <- predict(rf, test)
predict.svm <- predict(svm, test)
predict.nn <- predict(nn, test)
predict.alom <- predict(alom, test)

## Crie fun��es e calcule as seguintes m�tricas entre a predi��o e os dados observados

# Coeficiente de determina��o: R^2
r2 <- function(observations, predictions) {
  return (1 - (sum((test$VOL - predictions) ^ 2) / sum((test$VOL - mean(test$VOL)) ^ 2)))
}

# Erro padr�o da estimativa: Syx
syx <- function(observations, predictions) {
  return (sqrt((sum((test$VOL - predictions) ^ 2) / (length(test$VOL) - 2))))
}

# Syx%:
syx_percent <- function(observations, predictions) {
  return (syx(observations, predictions) / mean(test$VOL) * 100)
}

# Calcula m�tricas para o modelo baseado em Random Forest:
rf_r2 <- r2(test$VOL, predict.rf)
rf_syx <- syx(test$VOL, predict.rf)
rf_syx_percent <- syx_percent(test$VOL, predict.rf)

# Calcula m�tricas para o modelo baseado em SVM:
svm_r2 <- r2(test$VOL, predict.svm)
svm_syx <- syx(test$VOL, predict.svm)
svm_syx_percent <- syx_percent(test$VOL, predict.svm)

# Calcula m�tricas para o modelo baseado em Neural Network:
nn_r2 <- r2(test$VOL, predict.nn)
nn_syx <- syx(test$VOL, predict.nn)
nn_syx_percent <- syx_percent(test$VOL, predict.nn)

# Calcula m�tricas para o modelo alom�trico de Spurr:
alom_r2 <- r2(test_data$VOL, predict.alom)
alom_syx <- syx(test_data$VOL, predict.alom)
alom_syx_percent <- syx_percent(test_data$VOL, predict.alom)

## An�lise do modelo final:
final_model <- data.frame('RF' = c(rf_r2, rf_syx, rf_syx_percent),
           'SVM' = c(svm_r2, svm_syx, svm_syx_percent),
           'NN' = c(nn_r2, nn_syx, nn_syx_percent),
           'ALOM' = c(alom_r2, alom_syx, alom_syx_percent), 
           row.names = c('$R^2$', 'Syx','Sxy%'))
final_model
#         RF           SVM          NN           ALOM
# $R^2$   0.8180272    0.6470441    0.8400591    0.9319330
# Syx     0.2213733    0.3083061    0.2075400    0.1353912
# Sxy%    15.8802745   22.1164298   14.8879408   9.7123257

# O modelo alom�trico � o que obteve os melhores resultados de acordo com os 
# c�lculos das fun��es: coeficiente de determina��o e o erro padr�o da 
# estimativa (com apenas 9.7% de erro).

# Salvar modelo final:
saveRDS(final_model, "volume_arvores_final_model.rds")

# Salvar este script:
setwd("C:/Projects/ia_ufpr/linguagem_r/trabalho_final/2_estimativa_volumes_arvores")
getwd()
save(final_model, file="volumes_arvores_commands.RData")