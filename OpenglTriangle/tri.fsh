

#version 300 core

precision highp float;

uniform vec4 customColor;
out vec4 color;

void main() {
    //color = vec4(1.0, 1.0, 1.0, 1.0);
    color = customColor;
}




