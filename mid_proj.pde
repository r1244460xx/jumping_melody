
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.LinkedList;

class Beat {
    static final int size = 200;
    public int x;
    public int y;
    public int ans;
    public int time;
    public int effect;    
 
    Beat() {
    }
       
    void move() {
        x = width - int((Game.distance / Game.speed) * ((millis() - game.start_time) - (time - Game.speed)));
    }
} 

class Volume extends Beat {
    static final int chk_x = 400;
    static final int chk_y = 450;
    static final int up = 0;
    static final int left = 1;
    static final int down = 2;
    static final int right = 3;
    
    Volume(int t, int e) {
        x = width;         
        time = t;
        ans = int(random(4));
        ans = 0;
        y = chk_y;  
        effect = e;
    }
    
    Volume() {
    }
    
    void draw(){
        switch(ans) {
                case 0:
                    image(vol_up, x, y, size, size);
                    break;
                
                case 1:
                    image(vol_left, x, y, size, size);
                    break;
                
                case 2:
                    image(vol_down, x, y, size, size);
                    break;
                
                case 3:
                    image(vol_right, x, y, size, size);
                    break;
            }
    }
    
}

class Arrow extends Beat {
    static final int chk_x = 400;
    static final int chk_y = 700;
    static final int up = 0;
    static final int left = 1;
    static final int down = 2;
    static final int right = 3;
    
    Arrow(int t, int e) {
        ans = int(random(4));
        y = chk_y;
        x = width;         
        time = t;
        effect = e;
    }
    
    Arrow() {
    }
    
    void draw(){
        switch(ans) {
                case 0:
                    image(arr_up, x, y, size, size);
                    break;
                
                case 1:
                    image(arr_left, x, y, size, size);
                    break;
                
                case 2:
                    image(arr_down, x, y, size, size);
                    break;
                
                case 3:
                    image(arr_right, x, y, size, size);
                    break;
            }
    }
}

class Rank {
    public int counter = 0;
    public int rank;
    static final int x_size = 400;
    static final int y_size = 250;
    static final int bad = 1;
    static final int normal = 2;
    static final int excellent = 3;
    
    Rank(int e) {
        rank = e;
        counter = 15;
        if(e == normal) {
            if(game.is_bonus) {
                values.score += 20;
            }
            else {
                values.score += 10;
            }
        }
        else if(e == excellent) {
            if(game.is_bonus) {
                values.score += 40;
            }
            else {
                values.score += 20;
            }
        }
    }
    
    Rank() {
    }
      
    void draw() {
        if(counter > 0) {
            switch(rank) {
            case bad:
                image(bad_img, x_size, y_size);
                break;
                
            case normal:
                image(normal_img, x_size, y_size);
                break;
                
            case excellent:
                image(excellent_img, x_size, y_size);
                break;
                
            default:
                break;
            }
            counter--;
        }
    }   
}

class Value {
    static final int x = 400;
    static final int y = 75;
    int score = 0;
    int combo = 0;
    
    void draw() {
        fill(0);
        textSize(48);
        text(score, x, y);
            if(combo > 0) {
            text(combo + " combo", 150, 400);
        }
    }
}

class Game {
    public boolean is_standby = true;
    public boolean is_bonus = true;
    public int start_time = 0; 
    static final int fps = 144;  
    static final int w = 1600; 
    static final int h = 900;
    static final int distance = 1200;
    static final float speed = 1200.0;
    int vol_chk = 0;
}

PImage backgnd_img1, backgnd_img2, logo, bonus;
PImage vol_up, vol_left, vol_down, vol_right;
PImage arr_up, arr_left, arr_down, arr_right;
PImage arr_up_op, arr_left_op, arr_down_op, arr_right_op, arr_null_op;
PImage bad_img, normal_img, excellent_img;

int frame = 0;
int fps_time = 0;
int frame_1_sec = 0;

Rank rank;
BufferedReader reader;
//LinkedList<Beat> beatmap = new LinkedList<Beat>();
LinkedList<Volume> vol_queue = new LinkedList<Volume>();
LinkedList<Arrow> arr_queue = new LinkedList<Arrow>();
LinkedList<Volume> vol_beatmap = new LinkedList<Volume>();
LinkedList<Arrow> arr_beatmap = new LinkedList<Arrow>();

Serial port;
Minim minim;  //music obj
AudioPlayer player = null; //music player obj
AudioPlayer up_sound = null;
AudioPlayer down_sound = null;
Value values;
Game game;

void port_init() {
    try {
        port = new Serial(this, Serial.list()[0], 115200);
    }
    catch(Exception e) {
        println("Please check your serial connection");
        retry();  
    }
}

void draw_background() {
    if(game.is_standby) {  //standby page         
        background(backgnd_img1);                    
        String any_key = "Please key ENTER to start!";
        fill(#FFFFFF);
        textSize(80);
        textAlign(CENTER, CENTER);
        text(any_key, 800, 450); //Hope to create fading in out text
    }
    
    else {      //gaming page
        background(backgnd_img2);
        if(game.is_bonus) {
            image(bonus, 800, 100);            
        }                   
    }
}

void draw_cursor() {
    switch(game.vol_chk) {
        case Volume.up:
            image(vol_up, Volume.chk_x, Volume.chk_y, Volume.size, Volume.size); 
            break;
            
        case Volume.left:
            image(vol_left, Volume.chk_x, Volume.chk_y, Volume.size, Volume.size); 
            break; 
            
        case Volume.down:
            image(vol_down, Volume.chk_x, Volume.chk_y, Volume.size, Volume.size); 
            break;
        
        case Volume.right:
            image(vol_right, Volume.chk_x, Volume.chk_y, Volume.size, Volume.size); 
            break; 
            
        default:
            image(vol_up, Volume.chk_x, Volume.chk_y, Volume.size, Volume.size); 
            break;
    }
    
    if(arr_queue.size() > 0) {
        switch(arr_queue.element().ans) {
          case Arrow.up:
              image(arr_up_op, Arrow.chk_x, Arrow.chk_y, Arrow.size, Arrow.size); 
              break;
              
          case Arrow.left:
              image(arr_left_op, Arrow.chk_x, Arrow.chk_y, Arrow.size, Arrow.size); 
              break; 
              
          case Arrow.down:
              image(arr_down_op, Arrow.chk_x, Arrow.chk_y, Arrow.size, Arrow.size); 
              break;
          
          case Arrow.right:
              image(arr_right_op, Arrow.chk_x, Arrow.chk_y, Arrow.size, Arrow.size); 
              break;            
        }
    }
    else {
        image(arr_null_op, Arrow.chk_x, Arrow.chk_y, Arrow.size, Arrow.size);
    }
    
    for(int i = 0; i < vol_queue.size(); i++) {
        vol_queue.get(i).draw();
    }
    
    for(int i = 0; i < arr_queue.size(); i++) {
        arr_queue.get(i).draw();
    }
}

void move_beat() {                        //move all cursor
    for(int i = 0; i < vol_queue.size(); i++) {         
        vol_queue.get(i).move();
    }
    
    for(int i = 0; i < arr_queue.size(); i++) {        
        arr_queue.get(i).move();
    }
    
    if(vol_queue.size() > 0) {
        if(vol_queue.element().x <= Volume.chk_x) {
            if(vol_queue.element().ans != game.vol_chk) {  
                rank = new Rank(Rank.bad);
                values.combo = 0;
            }
            else {
                rank = new Rank(Rank.excellent);
                up_sound.rewind();
                up_sound.play();               
                values.combo++;
            }
            vol_queue.remove();
        }
    }
    
    if(arr_queue.size() > 0) {                        
        if(arr_queue.element().x < Arrow.chk_x - Beat.size / 2) {
            arr_queue.remove();
            rank = new Rank(Rank.bad);
            values.combo = 0;
        }
    }
}

void chk_down_res(int res) {
    if(arr_queue.size()>0) {  //not sensitive at all!
        if(abs(arr_queue.element().time - (millis() - game.start_time)) < 50 && abs(arr_queue.element().x - Arrow.chk_x) <= Beat.size / 2) {
            if(arr_queue.element().ans == res) {
                arr_queue.remove();
                rank = new Rank(Rank.excellent);
                values.combo++;
            }
            else {
                arr_queue.remove();
                rank = new Rank(Rank.bad);
                values.combo = 0;
            }       
        }         
        else if(abs(arr_queue.element().time - (millis() - game.start_time)) < 100 && abs(arr_queue.element().x - Arrow.chk_x) <= Beat.size / 2) {
            if(arr_queue.element().ans == res) {
                arr_queue.remove();
                rank = new Rank(Rank.normal);
                values.combo++;
            }
            else {
                arr_queue.remove();
                rank = new Rank(Rank.bad);
                values.combo = 0;
            }
        }        
    } 
}

void update_queue() {
    if(vol_beatmap.size() != 0) {
        if(vol_beatmap.element().time - (millis() - game.start_time) <= Game.speed) {   //From side to check point taking one second
            vol_queue.add(vol_beatmap.remove());
        }
    }
    if(arr_beatmap.size() != 0) {
       if(arr_beatmap.element().time - (millis() - game.start_time) <= Game.speed) {   //From side to check point taking one second
          arr_queue.add(arr_beatmap.remove());
       }
    }                  
}

void retry() {
    values.combo = 0;
    values.score = 0;
    player.pause();
    player.rewind();
    vol_beatmap.clear();
    arr_beatmap.clear();
    vol_queue.clear();
    arr_queue.clear();
    rank = new Rank();
    beatmap_init();
} 

void read_port() {
    if(port.available() > 0) {
        //int val = port.read();
    }
}
 
void draw_true_fps() {
    frame++;
    if(millis() - fps_time >= 1000) {
        fps_time = millis();
        frame_1_sec = frame;       
        frame = 0;
    }
    println(frame_1_sec);
}


void draw_fps() {
    fill(#FFFFFF);
    textSize(32);
    text("FPS: " + int(frameRate), 150, 850);
}

/*
void keyReleased() {
    switch(keyCode){
        case LEFT:
            break;
            
        case RIGHT:
            break;
            
        case DOWN: 
            break;
            
        case UP:
            break;   
    }
}*/

void keyPressed() {
    switch(keyCode){
        case UP:
            chk_down_res(Arrow.up);
            down_sound.rewind();
            down_sound.play(); 
            break; 
            
        case LEFT:
            chk_down_res(Arrow.left);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case DOWN:
            chk_down_res(Arrow.down);
            down_sound.rewind();
            down_sound.play(); 
            break;   
            
        case RIGHT:
            chk_down_res(Arrow.right);
            down_sound.rewind();
            down_sound.play(); 
            break;        
    }
    
    switch(key) {
        case 'q':
            game.is_standby = true;
            retry();
            break;
                       
        case '8':
            game.vol_chk = Volume.up;
            break;
            
        case '4':
            game.vol_chk = Volume.left;
            break;
            
        case '2':
            game.vol_chk = Volume.down;
            break;
            
        case '6':
            game.vol_chk = Volume.right;
            break;
            
        case '\n':
            if(game.is_standby) {
                game.is_standby = false;
                game.start_time = millis();
            }
            break;
    }   
}

void sound_init() {
        minim = new Minim(this);
        player = minim.loadFile("g_major_cut.mp3", 2048); //(filename, buffersize);
        up_sound = minim.loadFile("up_sound.wav");
        down_sound = minim.loadFile("down_sound.wav");
    }

void img_init() {
    try {
        imageMode(CENTER);
        backgnd_img2 = loadImage("background.png"); //Make a beautiful background-image
        logo = loadImage("logo.png");  //Make a beautiful logo image  
        bonus = loadImage("bonus.png");
        backgnd_img1 = loadImage("background_1.png");
        backgnd_img2 = loadImage("background_3.png"); 
        
        vol_up = loadImage("vol_up.png");
        vol_left = loadImage("vol_left.png");
        vol_down = loadImage("vol_down.png");
        vol_right = loadImage("vol_right.png");
        
        arr_up = loadImage("arr_up.png");
        arr_left = loadImage("arr_left.png");
        arr_down = loadImage("arr_down.png");
        arr_right = loadImage("arr_right.png");
        
        arr_up_op = loadImage("arr_up_op.png");
        arr_left_op = loadImage("arr_left_op.png");
        arr_down_op = loadImage("arr_down_op.png");
        arr_right_op = loadImage("arr_right_op.png");
        arr_null_op = loadImage("arr_null_op.png");
        
        bad_img = loadImage("bad.png");
        normal_img = loadImage("normal.png");
        excellent_img = loadImage("excellent.png");
    }
    catch(Exception e) {
        println("Please check your png file integration");
    }
}
   
void beatmap_init() {
    try {
        reader = createReader("g_major.csv");
    }
    catch(Exception e) {
        println("Please check your beatmap file");
        e.printStackTrace();
    }
    String line;
    while(true) {
        try {
            line = reader.readLine();             
        }
        catch(IOException e) {
            e.printStackTrace();
            line = null;
        }
        if(line == null) {
            break;
        }
        String[] data = split(line, ',');
        if(int(data[1]) == 0) {
            Volume obj = new Volume(int(data[2]), 0);
            vol_beatmap.add(obj);
        }
        else {
            Arrow obj = new Arrow(int(data[2]), 0);
            arr_beatmap.add(obj);
        }
    }   
}

void setup() {   
    game = new Game();
    rank = new Rank();   
    values = new Value();
    img_init();
    beatmap_init();
    sound_init();
    //port_init();
    size(1600, 900);
    frameRate(Game.fps);  //Now it reached 40 FPS    
    //Start a thread
}

void draw() {  //main function of this program        
    draw_background();
    if(!game.is_standby) {    //gaming mode
        update_queue(); 
        move_beat();
        player.play();      
        //read_port(); 
        //draw_true_fps();
        draw_cursor(); 
        values.draw();
        rank.draw();
    } 
    draw_fps();
}
