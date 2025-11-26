devtools::load_all()
library(gstat)
library(sp)
data(meuse)
coordinates(meuse) = ~x+y

set.seed(421)

# quick train/validation split
ids = sample(seq_len(nrow(meuse)), size = floor(0.7 * nrow(meuse)))
train = meuse[ids, ]
valid = meuse[-ids, ]

# build empirical variogram for 'zinc' on train
emp_train = gstat::variogram(zinc ~ 1, data = train)
plot(emp_train)

# fit a simple spherical model
vgm_start = vgm(model = "Sph", nugget = 30000)
fit_train = gstat::fit.variogram(emp_train, model = vgm_start)
plot(emp_train, fit_train)

emp_valid = gstat::variogram(zinc ~ 1, data = valid)
fit_valid = gstat::fit.variogram(emp_valid, model = vgm_start)
plot(emp_valid, fit_valid)

# compute SSVR for fitted models
ssvr_train = vgm_ssvr(fit_train)
ssvr_train
ssvr_valid = vgm_ssvr(fit_valid)
ssvr_valid

# compute AUC and similarity
auc_train = vgm_auc(fit_train, maxdist = 1200)
auc_train
auc_valid = vgm_auc(fit_valid, maxdist = 1200)
auc_valid
auc_res = vgm_compare(fit_train, fit_valid, maxdist = 1200)
auc_res
