shader_type canvas_item;

// how far along in the animation are we?
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// how big our screen sub division is
uniform float diamondPixelSize : hint_range(5.0, 50.0) = 10.0;

// wipe direction
uniform int wipeDirection : hint_range(0, 8) = 1;

void fragment() {
  float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
  float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
  float xDistance = abs(xFraction - 0.5);
  float yDistance = abs(yFraction - 0.5);
  
  bool test = false;
  
  switch (wipeDirection) {
    case 0: // fill stationary
      test = (xDistance + yDistance > progress * 2.0);
      break;
      
    case 1: // fill TL to BR 
      test = (xDistance + yDistance + UV.x + UV.y > progress * 4.0);
      break;
    case 2: // fill BR to TL
      test = (xDistance + yDistance + UV.x + UV.y < (1.0 - progress) * 4.0);
      break;
      
    case 3: // fill BL to TR
      test = ((1.0 - xDistance) + (1.0 - yDistance) + (UV.x - UV.y) > progress * 3.0);
      break;
    case 4: // fill TR to BL
      test = ((1.0 - xDistance) + (1.0 - yDistance) + (UV.x - UV.y) < (1.0 - progress) * 3.0);
      break;
      
    case 5: // fill left to right
      test = (xDistance + yDistance + UV.x > progress * 2.0);
      break;
    case 6: // fill right to left
      test = (xDistance + yDistance + UV.x < (1.0 - progress) * 2.0);
      break;
      
    case 7: // fill top to bottom
      test = (xDistance + yDistance + UV.y > progress * 2.0);
      break;
    case 8: // fill bottom to top
      test = (xDistance + yDistance + UV.y < (1.0 - progress) * 2.0);
      break;
  }
  
  if (test) {
    discard;
  }
}