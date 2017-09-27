"""Recipe helper"""
class RecipeHelper(object):
    @staticmethod
    def generate_recipe(filelist, coverage_id, base_recipe = None):
        import_config = {
            "service_url": "http://localhost:8080/rasdaman/ows",
            "tmp_directory": "/tmp/",
            "crs_resolver": "http://localhost:8080/def/",
            "default_crs": "http://localhost:8080/def/crs/OGC/0/Index2D",
            "mock": False,
            "automated": True
        }
        
        if not base_recipe:
            base_recipe = {
                "name": "map_mosaic",
                "options": {
                    "tiling": "REGULAR [0:256, 0:102]",
                    "wms_import": true
                }
            }
        
        final_recipe = {
            "config": import_config,
            "input": {
                "coverage_id": coverage_id,
                "paths": [ filelist ]
            },
            "recipe": base_recipe
        }

        return json.dumps(final_recipe)
