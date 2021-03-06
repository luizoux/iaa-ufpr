### ---------------------------------------------------------------------------- 
### 
### Estat�stica Aplicada II 
### Segunda Lista de Exerc�cios
###
### ----------------------------------------------------------------------------

# Com a base de dados "prostate" obter os seguintes resultados com o aux�lio do "R" .
install.packages('readxl')
library(readxl)
prostate <- read_excel("C:/Projetos/iaa-ufpr/estatistica_aplicada_ii/atividade_2/prostate.xlsx")

### ------- 
# a) Elaborar a regress�o linear preliminar com as seguintes vari�veis: 
#    - Vari�vel dependente: lcavol; 
#    - Vari�veis explicativas: lweight, age, lbph, svi, lcp, gleason, pgg45, lpsa.
install.packages('Rcmdr')
install.packages('RcmdrMisc')
library(Rcmdr)
library(RcmdrMisc)

result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa, data = prostate)
summary(result)

prostate <- within(prostate, {
  residuos <- residuals(result)
})


### ------- 
# b) Testar outliers pela t�cnicas de Grubbs, qui-quadrado, Bonferroni e da Dist�ncia  de Cook e eliminar observa��es se necess�rio.
## Grubbs
library ("outliers")
grubbs.test(prostate$residuos, type = 10, opposite = FALSE, two.sided = TRUE)

## qui-quadrado
chisq.out.test(prostate$residuos,opposite=FALSE)

#
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
prostate <- prostate[-c(69),]
chisq.out.test(prostate$residuos,opposite=FALSE)

#
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
prostate <- prostate[-c(55),]
chisq.out.test(prostate$residuos,opposite=FALSE)

#
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
prostate <- prostate[-c(12),]
chisq.out.test(prostate$residuos,opposite=FALSE)

## Bonferroni 
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
library (car)
outlierTest(result)

## Dist�ncia  de Cook
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
prostate_size <- nrow(prostate)
prostate$cooksd <- cooks.distance(result)
prostate$outlier <- with(prostate, ifelse(cooksd > 4/prostate_size,"yes","no"))
prostate[prostate$outlier != "no", ]

prostate <- prostate[-c(1,2,3,4,5,6),]
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa , data = prostate)
summary(result)


### -------
# c) Testar normalidade por Kolmogorov-Smirnov e Shapiro-Wilk.
## Kolmogorov-Smirnov --
library("RcmdrMisc")
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
normalityTest(~residuos, test="lillie.test", data=prostate)

## Shapiro-Wilk --
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa
             , data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
normalityTest(~residuos, test="shapiro.test", data=prostate)


### -------
# d) Testar autocorrela��o e corrigir com HAC se for o caso.
library(lmtest)
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason 
             + pgg45 + lpsa, data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
dwtest(lcavol ~  lweight + age + lbph + svi + lcp + gleason + pgg45 + lpsa, 
       alternative="greater", data=prostate)


### -------
# e) Testar heterocedasticidade e corrigir se for o caso, com regress�o robusta ou  HC1.
library(lmtest)
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason 
             + pgg45 + lpsa, data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
bptest(lcavol ~  lweight + age + lbph + svi + lcp + gleason 
            + pgg45 + lpsa, studentize=FALSE, data=prostate)

chisup <- qchisq(0.95, df=8)
chisup


### -------
# f) Fazer regress�o stepwise e obter a melhor regress�o, apresentar o resultado do  modelo.
# Models by STEPWISE - use BIC for calculation
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason 
             + pgg45 + lpsa, data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
lm(formula = lcavol ~ lcp + lpsa, data = prostate)
stepwise(result, direction= 'backward', criterion ='BIC')

result_stepwise <- lm(formula = lcavol ~ lcp + lpsa, data = prostate)
summary(result_stepwise)


### -------
# g) Obter o AIC, BIC e AICc do melhor modelo selecionado. 
result <- lm(lcavol ~  lweight + age + lbph + svi + lcp + gleason 
             + pgg45 + lpsa, data = prostate)
prostate <- within(prostate, {
  residuos <- residuals(result) 
})
library(AICcmodavg)
AIC (result)
BIC (result)
AICc (result)


### -------
# h) Estimar os Intervalos de confian�a dos par�metros. 
library(performance)
model_performance(result)
model_performance(result_stepwise)

confint(result)
confint(result_stepwise)
