// .OBJ Loader
// by SAITO <http://users.design.ucla.edu/~tatsuyas> 
// Placing a virtual structure represented as mathematically 
// three-dimensional object.
// OBJModel.load() reads structure data of the object stored 
// as numerical data.
// OBJModel.draw() gives a visual form to the structure data.
// processing standard drawing functions can be used to manipulate
// the visual form to create deep visual experiences.
// Created 20 April 2005
import saito.objloader.*;
import processing.opengl.*;
OBJModel model;
float rotX;
float rotY;
               
void setup()
{ 
   size(400, 400, OPENGL);
   model = new OBJModel(this, "dma.obj");
}

void draw()
{
   background(51);
   noStroke();
   lights();
   
   pushMatrix();
   translate(width/2, height/2, 0);
   rotateX(rotY);
   rotateY(rotX);
   scale(20.0);
   model.drawMode(POLYGON);
   model.draw();
   popMatrix();
}
void keyPressed()
{
   if(key == 'a')
   model.enableTexture();

   else if(key=='b')
   model.disableTexture();
}
void mouseDragged()
{
   rotX += (mouseX - pmouseX) * 0.01;
   rotY -= (mouseY - pmouseY) * 0.01;
}
