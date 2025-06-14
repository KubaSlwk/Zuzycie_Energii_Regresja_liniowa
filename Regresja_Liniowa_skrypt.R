library(ggplot2)
library(corrplot)
library(DescTools)
library(MASS)


# 1. Wczytanie i eksploracja danych
energy_data <- read.csv("train_energy_data.csv")
energy_test_data <- read.csv("test_energy_data.csv")

head(energy_data)

#Typy danych
str(energy_data)

nrow(energy_data)
#Suma pustych wartosci
colSums(is.na(energy_data))

#Statystyki opisowe
summary(energy_data)

#Zmiana zmiennych kategorycznych na numeryczne
energy_data$Day.of.Week <- as.factor(energy_data$Day.of.Week)
energy_data$Building.Type <- as.factor(energy_data$Building.Type)
energy_test_data$Day.of.Week <- as.factor(energy_test_data$Day.of.Week)
energy_test_data$Building.Type <- as.factor(energy_test_data$Building.Type)

# 2. Wizualizacja i analiza eksploracyjna

# Test istotności współczynnika korelacji Pearsona
num_data <- energy_data[sapply(energy_data, is.numeric)]
vars = subset(num_data, select = -c(Energy.Consumption))
vars_names <- names(vars)

#H0: Brak korelacji między zmiennymi (współczynnik równy 0)
#HA: Korelacją występuje między zmiennymi (współczynnik różny od 0)

for (var in vars_names) {
  test <- cor.test(energy_data$Energy.Consumption, vars[[var]])
  print(test)
}

cor_matrix_num <- cor(num_data, use = "complete.obs", method = "pearson")
corrplot(cor_matrix_num, method = "number", type = "upper", tl.cex = 0.6, tl.col = "black")


ggplot(energy_data, aes(x = Square.Footage, y = Energy.Consumption)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Zależność między powierzchnią budynku a zużyciem energii",
    x = "Powierzchnia budynku (Square Footage)",
    y = "Zużycie energii (kWh)"
  )

ggplot(energy_data, aes(x = Number.of.Occupants, y = Energy.Consumption)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Zależność między liczbą mieszkańców a zużyciem energii",
    x = "Liczba mieszkańców (Number of occupants)",
    y = "Zużycie energii (kWh)"
  )


# Model regresji liniowej

model <- lm(Energy.Consumption ~ 
     Square.Footage +
     Number.of.Occupants + 
     Appliances.Used +
     Building.Type + 
     Day.of.Week, data = energy_data)

summary(model)

influence.measures(model)
cooks.distance(model)

# Założenia regresji liniowej

library(ggfortify)
autoplot(model)

boxcox(model)

residuals = residuals(model)
hist(sample(residuals, 500))

set.seed(432)
shapiro.test(sample(residuals, 500))
# brak normalności rozkładu reszt

predictions = predict(model, newdata=energy_test_data)

MAE(energy_test_data$Energy.Consumption, predictions)
MSE(energy_test_data$Energy.Consumption, predictions)
