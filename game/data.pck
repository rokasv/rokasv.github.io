GDPC                                                                                    res://Game.tscn.converted.scn�      �*      �M�l�{�\Zݛ}���   res://icon.png�,      �
      ������윫��EǨ   res://icon.png.flags67             ���	�����t GD*   res://scripts/DataTween.gdcH7            @MQ��pE��x�v�   res://sprites/sprites.pngg<      l      �,W�O>���x8f�   res://engine.cfb�A      �      L�ج;���r=RSRC                    PackedScene                                                                       .        graph    bg    input    area0    area1    area2    area3    area4    area5    window    resource/name    script/source    custom_solver_bias    points    script/script 	   _bundled       Texture    res://sprites/sprites.png    
   local://1 �      
   local://2       
   local://3 T	      
   local://4 �      
   local://5 �      
   local://6 5      
   local://7 �      
   local://8 �      
   local://9 4         local://10 �         local://11 �         res://Game.tscn.convert.tscn       	   GDScript          c  extends Node2D

func _ready():
	OS.set_low_processor_usage_mode(true)
	
	var values = [0, 0.5, 0.4, 0.6, 0.9, 1]
	for i in range(values.size()):
		get_node("graph/bg/primaryCurve").set_point(i, values[i])
		get_node("graph/bg/secondaryCurve").set_point(i, values[i])
	
	get_node("graph/bg/secondaryCurve").color = Color("59553c")
	set_process_input(true) 	   GDScript          *  extends Node2D

onready var primaryCurve = get_node("bg/primaryCurve")
onready var secondaryCurve = get_node("bg/secondaryCurve")
onready var bg = get_node("bg")
onready var size = bg.get_region_rect().size

var trackingMouse = 0
var zoom = 1
var activIndex = -1

func _ready():
	set_process_input(true)
	for i in range(6):
		var input = get_node("input/area" + str(i))
		input.connect("mouse_enter", self, "set_trackingMouse", [true, i])
		input.connect("mouse_exit", self, "set_trackingMouse", [false, i])
#		input.connect("input_event", self, "handle_input")

func set_trackingMouse(value, index):
	print(value, index, get_local_mouse_pos())
	trackingMouse += 2*value-1
	if value == 0:
		secondaryCurve.points[index].smooth_to(primaryCurve.points[index].pos, 0.5)
		if index == activIndex: activIndex = -1
	else:
		activIndex = index

func set_lineWidth(value):
	primaryCurve.set_lineWidth(value)
	secondaryCurve.set_lineWidth(value)

func _input(event):
	if activIndex == -1: return 
	
	if event.type == InputEvent.MOUSE_MOTION:
		var rely = 1 - ( (event.pos/zoom - bg.get_pos())/size ).y
		secondaryCurve.set_point(activIndex, rely)
	elif event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
		primaryCurve.points[activIndex].smooth_to(secondaryCurve.points[activIndex].pos) 	   GDScript            extends Node2D

const topy = 0.5
const boty = 100.5
const DataTween = preload("res://scripts/DataTween.gd")

var lineWidth = 1
var lineScale = 1
var color = Color("8f906e")
var points = []

class Point:
	func _init(f):
		smoother = DataTween.new()
		father = f
	
	func smooth_to(nPos, time=0.3):
		smoother.interpolate_method(self, "set_pos", pos, nPos, time, Tween.TRANS_EXPO, Tween.EASE_OUT)
		smoother.start()
	
	func set_pos(value):
		pos = value
		father.update()
	
	var pos = Vector2(0,0)
	var smoother
	var father

func _ready():
	for i in range(6):
		points.append(Point.new(self))
		points.back().pos.x = 0.5 + 20*i
		add_child(points.back().smoother)

func set_point(number, value):
	assert(number >= 0 and number <= 5)
	value = clamp(value, 0, 1)
	var posy = lerp(boty, topy, value)
	points[number].pos.y = posy
	points[number].smoother.remove_all()
	update()

func set_lineWidth(value):
	lineWidth = value
	update()
	
func _draw():
	for i in range(points.size()-1):
		draw_line(points[i].pos, points[i+1].pos, color, lineWidth*lineScale)    ConvexPolygonShape2D                 %         B  �B  �A  �B  �A  �A   B  �A   ConvexPolygonShape2D                 %         B  �A  LB  �A  LB  �B   B  �B   ConvexPolygonShape2D                 %        LB  �A  �B  �A  �B  �B  LB  �B   ConvexPolygonShape2D                 %        �B  �A  �B  �A  �B  �B  �B  �B   ConvexPolygonShape2D                 %        �B  �A  �B  �A  �B  �B  �B  �B   ConvexPolygonShape2D                 %        �B  �A  �B  �A  �B  �B  �B  �B	   GDScript          &  extends Node

const base_size = Vector2(143, 143)

onready var camera = get_node("camera")

func _ready():
	var root = get_tree().get_root()
	root.connect("size_changed",self,"resize")
	
	OS.set_window_size(3*base_size)
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	resize()

func resize():
	var nsize = OS.get_window_size()
	
	var scale_w = max(int(nsize.x / base_size.x), 1)
	var scale_h = max(int(nsize.y / base_size.y), 1)
	var scale = min(scale_w, scale_h)
	var xextra = int(nsize.x) % scale
	var yextra = int(nsize.y) % scale
	xextra *= scale;
	yextra *= scale;
	var camScale = Vector2(1,1)/scale;
	camera.set_zoom(camScale)
	
	get_node("../graph").set_lineWidth(scale)
	get_node("../graph").zoom = scale
 	   GDScript          1  extends Camera2D

var offset = Vector2(0, 0)
var extraOffset = Vector2(0, 0)

func on_update(value):
	set_offset(value)

func set_offset(value):
	offset = value
	update_offset()
	
func set_extraOffset(value):
	extraOffset = value
	update_offset()

func update_offset():
	.set_offset(offset + extraOffset)    PackedScene          	         names "   �      Game    Node2D    script/script    graph    Node2D    script/script    bg    Sprite    transform/pos    texture 	   centered    region    region_rect    secondaryCurve    Node2D    script/script    primaryCurve    Node2D    transform/rot    script/script    input    Node    area0    Area2D    editor/display_folded    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    area1    Area2D    editor/display_folded    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    area2    Area2D    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    area3    Area2D    editor/display_folded    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    area4    Area2D    editor/display_folded    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    area5    Area2D    editor/display_folded    input/pickable    shapes/0/shape    shapes/0/transform    shapes/0/trigger    gravity_vec    gravity    linear_damp    angular_damp    CollisionPolygon2D    CollisionPolygon2D    build_mode    polygon    shape_range    trigger    window    Node    script/script    camera 	   Camera2D    visibility/visible    anchor_mode 	   rotating    current    zoom    limit/left 
   limit/top    limit/right    limit/bottom    drag_margin/h_enabled    drag_margin/v_enabled    smoothing/enable    smoothing/speed    drag_margin/left    drag_margin/top    drag_margin/right    drag_margin/bottom    script/script       node_paths                                                                                                                                                                                                                                                                                                 	                                         
                                         version             conn_count              node_count          	   variants    j                     
     �A  �A                                    �B  �B            �1��                                   �?          �?               
         �?     �B   ���=     �?       %         B  �A  �A  �A  �A  �B   B  �B
                                            �?          �?               
         �?     �B   ���=     �?       %         B  �A  LB  �A  LB  �B   B  �B
                                      �?          �?               
         �?     �B   ���=     �?       %        LB  �A  �B  �A  �B  �B  LB  �B
                                            �?          �?               
         �?     �B   ���=     �?       %        �B  �A  �B  �A  �B  �B  �B  �B
                                            �?          �?               
         �?     �B   ���=     �?       %        �B  �A  �B  �A  �B  �B  �B  �B
                                    	        �?          �?               
         �?     �B   ���=     �?       %        �B  �A  �B  �A  �B  �B  �B  �B
                        
                              
     �?  �?   �ig�   �ig�   ���    ���                         �@   ��L>   ��L>   ��L>   ��L>               nodes     `  ��������       ����                 @          ����               @          ����         	      
                        @          ����               @          ����            	         @          ����          @          ����	      
                                                          @    "   !   ����   #      $      %      &            @    (   '   ����	   )      *      +      ,      -      .      /      0      1            @    3   2   ����   4       5   !   6   "   7   #       	  @    9   8   ����   :   $   ;   %   <   &   =   '   >   (   ?   )   @   *   A   +       
  @    C   B   ����   D   ,   E   -   F   .   G   /         @    I   H   ����	   J   0   K   1   L   2   M   3   N   4   O   5   P   6   Q   7   R   8         @    T   S   ����   U   9   V   :   W   ;   X   <         @    Z   Y   ����	   [   =   \   >   ]   ?   ^   @   _   A   `   B   a   C   b   D   c   E         @    e   d   ����   f   F   g   G   h   H   i   I         @    k   j   ����	   l   J   m   K   n   L   o   M   p   N   q   O   r   P   s   Q   t   R         @    v   u   ����   w   S   x   T   y   U   z   V         @    |   {   ����   }   W         @       ~   ����   �   X   �   Y   �   Z   �   [   �   \   �   ]   �   ^   �   _   �   `   �   a   �   b   �   c   �   d   �   e   �   f   �   g   �   h   �   i             conns               editable_instances        RSRC�PNG

   IHDR   @   @   �iq�  
wIDATx��]LSi��|�i�-���������B]1#��F�YG�If&Y�Y�L�g�2��Y�n�7dܛ�dՌza��Xu �u�`�PP�(D
�V[���X���p�9���~dW��{���}�s���I��e5 v����t/��Ӵ�)))����  ��4����g~�LÏ�;���T.i�y `�c�A1�:u�) _�)�ό!��il?,K^,U�e
H�z8̦���%�@��V��|�=.L�}	��G��"��b�4g�6�0�3n&�O�  TC��B�,�w\�Ø�?*%�@����:���u��c�����3�����~6h�~��.�G(��C^�B��vX��iǝ3[PN�B��;~�X��x	6S��d<��t��f��>��U~�'pEyHK_F[��`�;fǸm$��u���րAD�b�-�S�͸�el�X(H�3Y��|㖈�bu���H$E�L�w�"0�'6O ����>�tS�T	�OG`��44U{�����	қ m���gx�nk�~$2R%�u�4�/��vD�eQ	����e�E�գd�\���.Ԇ4�Pz�n��A@����{-�&�|���T�>:��'���
L��p�>��M����C���`3�������`#G���n�r��s���1ؼ�mY���W#K(ŋ'?czj
 �r�f���"[Z  0yrY���(�e4��-�A�|u�7�ŅT���1ԇ�5��T��8�K6Y�s�|e��Ad
D�T��m��"�x�3&<�P�`#e��lz�LP�.�{�~U�:�h��uh��	f;����xc���O��~OOO� _W�(�����#5XP��B�MB^>��T �$���`t��á�T ��0^���J6���Cס>`�܏��/E�d2%I�
�iz�?��֦�uJJ
� S~��K�R����Eq�f14n���r]L�E�YP�B]���QP��=� w��P��	]W�+O�W��6�R������m��!��C�J�C�+(e����}Kn=�n�}>�6@��B�߶!�<���]kPV��n$����b�<�<';��m�� ��މY��.ȥ4�b���ɓ ���
TWW� ��/wo�7�
�m*5��ѣp�ݐH$����N�<w����I���ަ����^>|�n ���N�9s���P�T�\[���\hV�`sz��$2P�� p��I�4:���DC}#��V�ȑ# ���Ehl{��x�m�yK,������4>ȸ���U2Z9�U2|��/��b�oۀ�6���W$C&+gϞEC}cX}C}#��g�/L�c"f�dg��[ZZ���ׄ��^hV�h������<!/ P__ϨSCCC�:֑(�MQ�%�A���F&+1�g�$��m�f�w����=&���#��� ��gh~8  ���A��*��>�� t:�ݍ��o���qԝ�Y�̰z�$Ǐ���o�mX��o��ߏ9��}���Y�L|��A�ٳ�m�`dv�h��v*�
������:��ւ��  �y�n��E�ҏo���r��QSS���p8�T* @cۣ��d&���p�f�߶.���b�J�
5�����������E��9p�_�Z_�ʵ���t���h~8�[�|�����ϊ	�c3z�q�]t:	�@�bxl�y�Kخ0 d�
Q��E	��*
r�''��` �k��؇L���iJ�'�����?G��ؼ(�M$����>���1<�h��,� D��*���znb��CZ:Ab�YȖΜ	셵���n����	(���n�%��U�eF:���ٸ�#0߿�lY!To�HY��N�@����HY������:��Kxn������I!���-�!|N;��a�m#����r�D^�e�K�/���Ḥ�$��$'H/zo^���+7l�=c�i�DkP:�����/i�~:���2�Z��A�A�[����Q<a6�9d��{�s����_�)��]F�!��#6�粃��!�D��r�MTJ���>A�Lpe$B��pY�)߻�r;��?#G�_��$�E�"]��,x���uD)���cȄ)?	�ˇX]�h0�'`�n��Y�(����
<�h��ǀ>�U ��U�m�D��D�;�.@5@O�7��{���]V�`F�ل��&pDR�섌.�0&IC���J- D���j�� S~�MX��N�?�R��+����1��t81�>w\���:�-+d|\Q^�n�ӎ�{��G)))ᣀ��m�ŋzss���C&L��&I/l�np��e�x�����b�x��7qDҸ�Z��Ka�]�ޤx�a�!2�)?�{���b_7"�Ah=`>�:�z-)^�����`�נ��7��6�����d����B��}�/�)#�r`��]x��������t�w�jh�	�~��@^�<��v��!V�A�qKT��b�ۀ�;M�`�(0�ē0�-+�D�g�Zj\�aX���b�!
&N%,iJY�Be�{�}�[_l��X�6�`�T���.�a��
�x���´��9`�F�(��y��s��s9 L�N��������νa�6�X(`l�`���%|U��`� �4��unc.�R��'9u�"}�H����>    IEND�B`�gen_mipmaps=false
GDSC
   !          �      ����ض��   ���׶���   �����׶�   ���������Ӷ�   ����������Ӷ   ׶��   Զ��   ���ڶ���   ����������Ӷ   ����������ڶ   ��������Ӷ��   �������ض���   ��������ն��   ����������������������׶   ��ܶ   �������Ӷ���   ���۶���   �ٶ�   ���Ӷ���   ��������Ӷ��   �������Ӷ���   ����϶��   �����������������Ҷ�   �����϶�   ������¶   ���������������򶶶�   ���������Ѷ�   ����Ӷ��   ���¶���   �����������䶶��   �������ⶶ��   ����¶��   ��ζ   
   onComplete            	   on_update         tween_complete        on_complete    
   do_nothing                           	                                 	      
   %      *      +      2      ;      <      U      h      q      w      x      ~      �      �      �      �      �      �      �      �      �      �       4MM;�  BCM;�  MM@�  MM2�  F�  H�  GL�  �  &�  FG�  FGL�  �	  FGMM2�
  F�  GL�  �  J�  F�  H�  GMM2�  F�  H�  H�  H�  H�  H�  H�  H�  H�  �  GL�  �  FH�  H�  H�  H�  H�  H�  H�  G�  �  �+  F�  H�  G�  J�  �  MM2�  FGL�  �  F�  HH�  HBCH�  GMM2�  F�  GL1MM2�  F�  GL�  �  FH�  H�  H�  H�  HJ�  HJ�  G�  �  FGMM72�   F�  H�  H�  GL�  1�  �  F�  �  G�  P�PNG

   IHDR  ,  ,   y}�u  3IDATx���1�E����Ͱ6����j,9a�Đ}��X��8'����TP�}����`������� �><��_���_�?}|�O�Y����{������ۻ뽯�_m�������kl�������kl�������kl�������kl�������kl�������kl�������kl�������kl��֏K��O����뗧+a��O�'p�kl�y�5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��|�}�	�|�}�o���;��=����psa��7��psa��7��psa��7��psa��7��psa��7��psa��7��psa��7��psa��7��p�M��'p�M�1��7�����wXc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{�ͅ5��\Xc{��7�Ǟ��7����;ܼ��n�a��7��psa��7��psa��7��psa��7��psa��7��psa��7��psa��7��psa��7��psa�����+hx{>��� �ɻ�I�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, C���2�, ���q61_t    IEND�B`�ECFG      application/name         Gamecht    application/main_scene         res://Game.tscn    application/icon         res://icon.png     image_loader/filter             image_loader/gen_mipmaps          	   remap/all�            res://scripts/DataTween.gd     res://scripts/DataTween.gdc    res://Game.tscn    res://Game.tscn.converted.scn ��   render/default_clear_color      ��P>��H>��>  �?{C      GDPC