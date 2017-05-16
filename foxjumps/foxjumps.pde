// Ticha Sethapakdi, 2017
// Image manipulation inspired by Rorschach ink blots

// Make sure your images are in the 'data' folder first!

import java.util.Map;

// keeps track of the images we've already processed (so there are no repeats)
HashMap<Integer, Integer> processedimgs = new HashMap<Integer, Integer>();
PImage img; 

float threshold = 100;
int border = 100;  
int count = 0; 

// number of ink blots you want to make
int numoutputs = 17;  

void setup() { 
  // begone windows!
  surface.setVisible(false);
  size(3508, 2480);

  background(255);
  // make edges of shapes nice and smooth
  smooth();
  // outlines are gross
  noStroke();

  String path = dataPath("");
  File[] files = listFiles(path);
  int numfiles = files.length; 

  print("\nprocessing");
  for (int i = 0; i < numoutputs; i++) { 
    int idx = int(random(numfiles));

    // keep trying until you select an image you haven't processed yet
    while (processedimgs.containsKey(idx)) {
      idx = int(random(numfiles));
    }

    // remember that you processed this image
    processedimgs.put(idx, 1); 

    String filename = files[idx].getName(); 
    createInk(filename);
    print(".");
  }

  println("done.");
  exit();
}

// this function prepares to make a Rorschach ink blot from an image
// it doesn't really do much outside of calling the drawBlobs function
void createInk(String fileName) {
  img = loadImage(fileName);

  if ((height*0.6 / img.height ) * float(img.width) < width*0.35)
    img.resize(0, int(height*0.6));

  else
    img.resize(int(width*0.35), 0);

  int imgsize = img.width * img.height;

  // gets all the values ready for the drawBlobs function
  int loopmax1 = int(imgsize*0.006);
  int loopmax2 = int(imgsize*0.005);

  pushMatrix();
  translate(width/2-img.width, (height-img.height)/2); 

  // make blobs
  // drawBlobs is called twice to make the ink blots
  // more 'dimensional'; the bottom layer is slightly less opaque
  // than the top layer, which produces a watercolor-like effect
  drawBlobs(loopmax1, 30, 50, 1.2, 7, 0.3); 
  drawBlobs(loopmax2, 8, 15, 1.1, 4, 0.2);

  // make edges well-defined and sexy
  filter(POSTERIZE, 7);

  popMatrix();

  fill(100, 40);
  rect(border, border, width-border*2, height-border*2);

  saveFrame("imgs/"+ count+".jpg");
  fill(255);
  rect(0, 0, width, height);

  count++;
}

//taken from http://processing.org/learning/topics/directorylist.html
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else { 
    return null;
  }
}

// this function does the bulk of the blob-making
// essentially the trick is to repeatedly pick a pixel from the image at random
// and draw a small ellipse in its place
// the 'blur' filter blends all the ellipses together, 
// creating a bloblike form
void drawBlobs(int loopmax, int radmin, int radmax, 
  float stretch, int blur, float darkpercent) {
  int darkpixels = 0; 

  for (int i = 0; i < loopmax; i++) { 
    // pick some random pixel in the image
    int x = int(random(img.width));
    int y = int(random(img.height));

    int loc = x + y*img.width;

    img.loadPixels();

    // extract red, green, and blue components of the image
    float r = red(img.pixels[loc]);
    float g = green(img.pixels[loc]);
    float b = blue(img.pixels[loc]);

    // the grayness of an image is just an average of the 
    // red, green, and blue values
    float gray = (r+g+b)/3;

    if (brightness(img.pixels[loc]) <= threshold) {
      // you don't want the ink blot to end up looking
      // too murky, so stop making blobs once you have 
      // a certain proportion of darker pixels
      if (float(darkpixels)/loopmax > darkpercent) { 
        break;
      }

      // radius of the blob
      int radius = int(random(radmin, radmax));

      // this variable is true roughly 5% of the time
      // so 'blood' makes up of roughly 5% of the ink blot  
      boolean makeBlood = (random(100) < 5); 

      if (makeBlood) {
        // create a red blob 
        fill(#e73e2b, int(random(150, 200)));
      } else {
        fill(gray, int(random(85, 150)));
      }

      darkpixels++;

      float offsety = y+random(-200, 200);

      // draw the first ellipse 
      ellipse(x, offsety, radius*stretch, radius);
      // draw the 'reflection' of the first ellipse
      ellipse(img.width*2-x, offsety, radius*stretch, radius);
    }
  }

  filter(BLUR, blur);
}