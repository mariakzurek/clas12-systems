#!/usr/bin/env python3

# imports: do not edit these lines
import sys, os, argparse
import logging
import subprocess
from gemc_api_utils import GConfiguration
from gemc_api_geometry import *

from rgab_beamline import build_rgab_beamline
from rgh_beamline import build_rgh_beamline
from elmo_beamline import build_elmo_beamline
from transverseUpstream_beamline import build_transverseUpstream_beamline

from materials import define_materials

_logger = logging.getLogger("beamline")

VARIATIONS = {
    "FTOn",
    "FTOff",
    "ELMO",
    "rghFTOut",
    "rghFTOn",
    "TransverseUpstreamBeampipe"
}


def main():
	logging.basicConfig(level=logging.DEBUG)
	
	# Provides the -h, --help message
	desc_str = "   Will create the CLAS12 Beamline geometries\n"
	parser = argparse.ArgumentParser(description=desc_str)
	
	# loop over all the defined builder functions
	for variation in VARIATIONS:
	
		basepath = os.environ["GPLUGIN_PATH"]
	
		_logger.info(f"Building ft configuration for variation {variation}")
		# Define GConfiguration name, factory and description. Initialize it.
		configuration = GConfiguration('beamline', 'TEXT', 'The CLAS12 Beamline')
		configuration.setVariation(variation)
		configuration.init_geom_file()
		configuration.init_mats_file()
	
		# define materials
		define_materials(configuration)
	
		# build geometry
		if variation == "FTOn" or variation == "FTOff":
			build_rgab_beamline(configuration)
		elif variation == "ELMO":
			build_elmo_beamline(configuration)
		elif variation == "rghFTOut" or variation == "rghFTOn":
			# build_rgh_beamline(configuration)
			build_transverseUpstream_beamline(configuration)
		elif variation == "TransverseUpstreamBeampipe" :
			build_transverseUpstream_beamline(configuration)

		# print out the GConfiguration
		configuration.printC()


if __name__ == "__main__":
	main()






