library(testthat)
library(fars)
library(dplyr)
library(readr)
library(tidyr)
library(magrittr)
library(graphics)
library(maps)

# test make_filename
test_that("Testing the make_filename function", {
       expect_equal(make_filename(2013), "accident_2013.csv.bz2")})

test_that("Testing the make_filename function", {
       expect_equal(make_filename(2014), "accident_2014.csv.bz2")})

test_that("Testing the make_filename function", {
       expect_equal(make_filename(2015), "accident_2015.csv.bz2")})
