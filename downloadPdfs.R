# Set directories
	wd <- "/Users/cmmoore/ColbyDrive/Projects/HistTheory/get_pdf_data"
	pdf_wd <- paste0(wd, "/pdf")
	if (any(list.files(wd) == pdf_wd) == F) {
		dir.create(pdf_wd)	
	}

# Load libraries
	library(package = "httr")
#	library(package = "devtools")

# Import Am. Nat. DOIs
	ANcsv <- read.csv(file = "https://raw.githubusercontent.com/flodebarre/2020_AmNatHistory/master/data/mergedAmNat_abs.csv", stringsAsFactor = F)
	doi <- ANcsv$DOI
	rm(ANcsv); gc()

# Download files
	start <- proc.time()
	n_dois <- length(doi)
	html_pre <- "https://www.journals.uchicago.edu/doi/pdf"	
	for (i in 1:n_dois) {
		doi_i <- doi[i]
		url_str <- paste0(html_pre, "/", doi_i)
		doichar_repl <- gsub(pattern = "\\.|/", replacement = "_", x = doi_i)
		dest_str <- paste0(pdf_wd, "/", doichar_repl, ".pdf")
		if (!file.exists(dest_str) == F) {
			if (!http_error(url_str) == T) {
				download.file(url = url_str, destfile = dest_str, mode = "wb")
			} # end of no http error
		} # end of file exists
		if (i %% 100 == 1) {
				Sys.sleep(runif(n = 1, min = 61, max = 180))
			} else {
				Sys.sleep(runif(n = 1, min = 2, max = 10))
			}
	} # end of loop
	end <- proc.time()
	end - start
	# u1 <- url_str
	# u2 <- url_str
	# url.exists(u1)
	# url.exists(u2)
	# !http_error(u1)
	# !http_error(u2)	