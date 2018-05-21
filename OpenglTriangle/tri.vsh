

#version 300 core

precision highp float;

layout (location = 0) in vec3 position;
uniform vec3 positionOffset;

void main() {
    gl_Position = vec4(position + positionOffset, 1);
}



