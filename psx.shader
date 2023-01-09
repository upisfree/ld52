shader_type spatial; 
render_mode skip_vertex_transform, diffuse_burley; 

//Albedo texture 
uniform sampler2D albedoTex : hint_albedo; //Geometric resolution for vert sna[ 
uniform float snapRes = 16.0; 
uniform float roughness = 1.0;
uniform float specular = 0.1;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
//Controls the how much light it recieves
uniform float light_intensity = 0.3;

// For transparent textures
uniform bool transparent = false;

uniform bool is_black = false;

// cull mode disabled

//vec4 for UV recalculation 
varying vec4 vertCoord; 
void vertex() { 
	UV = UV * uv_scale + uv_offset;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz; 
	VERTEX.xyz = floor(VERTEX.xyz * snapRes) / snapRes;
	
	//if (is_black) {
	//	VERTEX.x += sin(TIME * 100.0) / 50.0;
	//	VERTEX.y += cos(TIME * 100.0) / 50.0;
	//}
	
	
	vertCoord = vec4(UV * VERTEX.x, VERTEX.z, 0); 
} 
void fragment() { 
	
	ROUGHNESS =roughness;
	SPECULAR = specular;
	
	if (is_black) {
		ALBEDO = vec3(0.0, 0.0, 0.0);
	} else {
		ALBEDO = texture(albedoTex, UV).rgb; 		
	}
	
	
	//Check if the texture is transparent
	if (transparent == true){
		// alpha value less than user-specified threshold 0.0?
		if (texture(albedoTex, UV).a <= 0.0)
        
    	{
        	discard; // yes: discard this fragment
    	}	
		
	}
	
	
	}
//QUICK FIX TO LIGHTING
void light()
{
	
	DIFFUSE_LIGHT = ALBEDO*LIGHT_COLOR*ATTENUATION*light_intensity;

}