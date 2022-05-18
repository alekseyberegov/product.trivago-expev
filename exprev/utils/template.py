import re
from typing import Dict

def render_template(template:str, macros: Dict) -> str:
    def replace_macro(match_obj):
        if match_obj.group(1) is not None:
            return macros[match_obj.group(1)[2:-1]] 

    return re.sub(r"(\$\{[A-Za-z_]+\})", replace_macro, template)
