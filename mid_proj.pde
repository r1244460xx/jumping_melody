
import processing.serial.*;
import gifAnimation.*;
import ddf.minim.*;
import java.util.LinkedList;

class Beat {
    static final int SIZE = 200;
    public int x;
    public int y;
    public int ans;
    public int time;
    public int effect;    
 
    Beat() {
    }
       
    void move() {
        x = width - int((DISTANCE / SPEED) * ((millis() - start_time) - (time - SPEED)));
    }
} 

class Volume extends Beat {
    static final int CHK_X = 400;
    static final int CHK_Y = 450;
    static final int UP = 0;
    static final int LEFT = 1;
    static final int DOWN = 2;
    static final int RIGHT = 3;
    
    Volume(int t, int e) {
        x = width;         
        time = t;
        ans = int(random(4));
        ans = 0;
        y = CHK_Y;  
        effect = e;
    }
    
    Volume() {
    }
    
    void draw(){
        switch(ans) {
                case 0:
                    image(vol_up, x, y, SIZE, SIZE);
                    break;
                
                case 1:
                    image(vol_left, x, y, SIZE, SIZE);
                    break;
                
                case 2:
                    image(vol_down, x, y, SIZE, SIZE);
                    break;
                
                case 3:
                    image(vol_right, x, y, SIZE, SIZE);
                    break;
        }
    }
}

class Arrow extends Beat {
    static final int CHK_X = 400;
    static final int CHK_Y = 700;
    static final int UP = 0;
    static final int LEFT = 1;
    static final int DOWN = 2;
    static final int RIGHT = 3;
    
    Arrow(int t, int e) {
        ans = int(random(4));
        y = CHK_Y;
        x = width;         
        time = t;
        effect = e;
    }
    
    Arrow() {
    }
    
    void draw(){
        switch(ans) {
                case 0:
                    image(arr_up, x, y, SIZE, SIZE);
                    break;
                
                case 1:
                    image(arr_left, x, y, SIZE, SIZE);
                    break;
                
                case 2:
                    image(arr_down, x, y, SIZE, SIZE);
                    break;
                
                case 3:
                    image(arr_right, x, y, SIZE, SIZE);
                    break;
            }
    }
}

class Rank {
    public int counter = 0;
    public int rank;
    static final int SIZE_X = 400;
    static final int SIZE_Y = 250;
    static final int BAD = 1;
    static final int NORMAL = 2;
    static final int EXCELLENT = 3;
    
    Rank(int e) {
        rank = e;
        counter = 15;
        if(e == NORMAL) {
            if(is_bonus) {
                values.score += 20;
            }
            else {
                values.score += 10;
            }
        }
        else if(e == EXCELLENT) {
            if(is_bonus) {
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
            case BAD:
                image(bad_img, SIZE_X, SIZE_Y);
                break;
                
            case NORMAL:
                image(normal_img, SIZE_X, SIZE_Y);
                break;
                
            case EXCELLENT:
                image(excellent_img, SIZE_X, SIZE_Y);
                break;
                
            default:
                break;
            }
            counter--;
        }
    }   
}

class Value {
    static final int X = 400;
    static final int Y = 75;
    int score = 0;
    int combo = 0;
    
    void draw() {
        fill(0);
        textSize(48);
        text(score, X, Y);
            if(combo > 0) {
            text(combo + " combo", 150, 400);
        }
    }
}

class Sound {
    static final int bass = 0;
    static final int middle = 1;
    static final int treble = 2;
    static final int cymbal = 3;   
}

static final int FPS = 60;  
static final int DISTANCE = 1200;
static final float SPEED = 1000.0;

PImage backgnd_img1, backgnd_img2, logo, bonus;
PImage vol_up, vol_left, vol_down, vol_right;
PImage arr_up, arr_left, arr_down, arr_right;
PImage arr_up_op, arr_left_op, arr_down_op, arr_right_op, arr_null_op;
PImage bad_img, normal_img, excellent_img;

public boolean is_standby = true;
public boolean is_bonus = true;
public int start_time = 0; 

int vol_chk = 0;

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
AudioPlayer hihat_cymbal = null;
AudioPlayer middle = null, cymbal = null, bass = null, treble = null;
Value values;

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
    if(is_standby) {  //standby page         
        background(backgnd_img1);                    
        String any_key = "Please key ENTER to start!";
        fill(#FFFFFF);
        textSize(80);
        textAlign(CENTER, CENTER);
        text(any_key, 800, 450); //Hope to create fading in out text
    }
    
    else {      //gaming page
        background(backgnd_img2);
        if(is_bonus) {
            image(bonus, 800, 100);            
        }                   
    }
}

void draw_beat() {
    switch(vol_chk) {
        case Volume.UP:
            image(vol_up, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
            break;
            
        case Volume.LEFT:
            image(vol_left, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
            break; 
            
        case Volume.DOWN:
            image(vol_down, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
            break;
        
        case Volume.RIGHT:
            image(vol_right, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
            break; 
            
        default:
            image(vol_up, Volume.CHK_X, Volume.CHK_Y, Volume.SIZE, Volume.SIZE); 
            break;
    }
    
    if(arr_queue.size() > 0) {
        switch(arr_queue.element().ans) {
          case Arrow.UP:
              image(arr_up_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
              break;
              
          case Arrow.LEFT:
              image(arr_left_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
              break; 
              
          case Arrow.DOWN:
              image(arr_down_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
              break;
          
          case Arrow.RIGHT:
              image(arr_right_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE); 
              break;            
        }
    }
    else {
        image(arr_null_op, Arrow.CHK_X, Arrow.CHK_Y, Arrow.SIZE, Arrow.SIZE);
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
        if(vol_queue.element().x <= Volume.CHK_X) {
            if(vol_queue.element().ans != vol_chk) {  
                rank = new Rank(Rank.BAD);
                values.combo = 0;
            }
            else {                
                rank = new Rank(Rank.EXCELLENT);
                play_effect(vol_queue.element().effect);              
                values.combo++;
            }
            vol_queue.remove();
        }
    }
    
    if(arr_queue.size() > 0) {                        
        if(arr_queue.element().x < Arrow.CHK_X - Beat.SIZE / 2) {
            arr_queue.remove();
            rank = new Rank(Rank.BAD);
            values.combo = 0;
        }
    }
}

void chk_arr_res(int res) {
    if(arr_queue.size()>0) {  
        if(abs(arr_queue.element().time - (millis() - start_time)) < 50 && abs(arr_queue.element().x - Arrow.CHK_X) <= Beat.SIZE / 2) {
            if(arr_queue.element().ans == res) {
                play_effect(arr_queue.element().effect);
                arr_queue.remove();
                rank = new Rank(Rank.EXCELLENT);
                values.combo++;
            }
            else {
                arr_queue.remove();
                rank = new Rank(Rank.BAD);
                values.combo = 0;
            }       
        }         
        else if(abs(arr_queue.element().time - (millis() - start_time)) < 100 && abs(arr_queue.element().x - Arrow.CHK_X) <= Beat.SIZE / 2) {
            if(arr_queue.element().ans == res) {
                play_effect(arr_queue.element().effect);
                arr_queue.remove();
                rank = new Rank(Rank.NORMAL);
                values.combo++;
            }
            else {
                arr_queue.remove();
                rank = new Rank(Rank.BAD);
                values.combo = 0;
            }
        }        
    } 
}

void update_queue() {
    if(vol_beatmap.size() != 0) {
        if(vol_beatmap.element().time - (millis() - start_time) <= SPEED) {   //From side to check point taking one second
            vol_queue.add(vol_beatmap.remove());
        }
    }
    if(arr_beatmap.size() != 0) {
       if(arr_beatmap.element().time - (millis() - start_time) <= SPEED) {   //From side to check point taking one second
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
            chk_arr_res(Arrow.UP);
            break; 
            
        case LEFT:
            chk_arr_res(Arrow.LEFT);
            break;   
            
        case DOWN:
            chk_arr_res(Arrow.DOWN);
            break;   
            
        case RIGHT:
            chk_arr_res(Arrow.RIGHT);
            break;        
    }
    
    switch(key) {
        case 'q':
            is_standby = true;
            retry();
            break;
                       
        case '8':
            vol_chk = Volume.UP;
            break;
            
        case '4':
            vol_chk = Volume.LEFT;
            break;
            
        case '2':
            vol_chk = Volume.DOWN;
            break;
            
        case '6':
            vol_chk = Volume.RIGHT;
            break;
            
        case '\n':
            if(is_standby) {
                is_standby = false;
                start_time = millis();
            }
            break;
    }   
}



void sound_init() {
    minim = new Minim(this);
    player = minim.loadFile("g_major_cut.mp3", 2048); //(filename, bufferSIZE);
    hihat_cymbal = minim.loadFile("hihat_cymbal.wav");
    middle = minim.loadFile("middle.wav");
    cymbal = minim.loadFile("cymbal.wav");
    bass = minim.loadFile("bass.wav");
    treble = minim.loadFile("treble.wav");
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
            Volume vol = new Volume(int(data[2]), int(data[3]));
            vol_beatmap.add(vol);
        }
        else {
            Arrow arr = new Arrow(int(data[2]), int(data[3]));
            arr_beatmap.add(arr);
        }
    }   
}

void play_effect(int s) {
    switch(s) {
        case Sound.bass:
            bass.rewind();
            bass.play();
            break;
        
        case Sound.middle: 
            middle.rewind();
            middle.play();
            break;
            
        case Sound.treble:
            treble.rewind();
            treble.play();
            break;
         
        case Sound.cymbal:
            cymbal.rewind();
            cymbal.play();
            break;          
    }
}

void setup() {   
    rank = new Rank();   
    values = new Value();
    img_init();
    beatmap_init();
    sound_init();
    //port_init();
    size(1600, 900);
    frameRate(FPS);  
    //Start a thread
}

void draw() {  //main function of this program        
    draw_background();
    draw_fps();
    if(!is_standby) {    //gaming mode
        update_queue(); 
        move_beat();
        player.play();      
        //read_port(); 
        //draw_true_fps();
        draw_beat(); 
        values.draw();
        rank.draw();
    } 
}
