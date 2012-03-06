# coding: shift_jis

#-----------------------------------------
# 球の表面をどこまでも拡大し続ける円のシュミレーション
# @author satou.jun
# @date   2011.12.23
#-----------------------------------------

require "rubygems"
require "opengl"
require "glut"

class ThreeDimentionAnimation

	LIGHT_POSITION = [0.25, 1.0, 0.25, 0.0]
	LIGHT_DIFFUSE  = [1.0, 1.0, 1.0]
	LIGHT_AMBIENT  = [0.25, 0.25, 0.25]
	LIGHT_SPECULAR = [1.0, 1.0, 1.0]

	MAT_DIFFUSE   = [1.0, 0.0, 0.0]
	MAT_AMBIENT   = [0.25, 0.25, 0.25]
	MAT_SPECULAR  = [1.0, 1.0, 1.0]
	MAT_SHININESS = [32.0]

	MAX_COUNT = 2500

	## ---------------------------------------------------------------------
	## - 角度からラジアンに変換する関数
	## ---------------------------------------------------------------------
	def getRadian(dblDegree)
		return dblDegree * (Math::PI / 180)
	end

	def DrawWireCube()

		GL.Begin(GL::LINE_LOOP)
		GL.Vertex3f(-5.0, 5.0, -5.0)
		GL.Vertex3f( 5.0, 5.0, -5.0)
		GL.Vertex3f( 5.0, 5.0,  5.0)
		GL.Vertex3f(-5.0, 5.0,  5.0)
		GL.End()

		GL.Begin(GL::LINE_LOOP)
		GL.Vertex3f(-5.0, -5.0, -5.0)
		GL.Vertex3f( 5.0, -5.0, -5.0)
		GL.Vertex3f( 5.0, -5.0,  5.0)
		GL.Vertex3f(-5.0, -5.0,  5.0)
		GL.End()

		GL.Begin(GL::LINES)
		GL.Vertex3f(-5.0, -5.0, -5.0)
		GL.Vertex3f(-5.0,  5.0, -5.0)
		GL.End()

		GL.Begin(GL::LINES)
		GL.Vertex3f( 5.0, -5.0, -5.0)
		GL.Vertex3f( 5.0,  5.0, -5.0)
		GL.End()

		GL.Begin(GL::LINES)
		GL.Vertex3f( 5.0, -5.0,  5.0)
		GL.Vertex3f( 5.0,  5.0,  5.0)
		GL.End()

		GL.Begin(GL::LINES)
		GL.Vertex3f(-5.0, -5.0,  5.0)
		GL.Vertex3f(-5.0,  5.0,  5.0)
		GL.End()

	end

	def DrawPointsSphere

		dbl半径 = 5.0;

		0.upto(MAX_COUNT - 2) do |intIndex|

			dblSx = dbl半径 * Math.cos(getRadian(@dbl仰角[intIndex])) * Math.sin(getRadian(@dbl俯角[intIndex]));
			dblSy = dbl半径 * Math.sin(getRadian(@dbl仰角[intIndex]));
			dblSz = dbl半径 * Math.cos(getRadian(@dbl仰角[intIndex])) * Math.cos(getRadian(@dbl俯角[intIndex]));

			dblEx = dbl半径 * Math.cos(getRadian(@dbl仰角[intIndex+1])) * Math.sin(getRadian(@dbl俯角[intIndex+1]));
			dblEy = dbl半径 * Math.sin(getRadian(@dbl仰角[intIndex+1]));
			dblEz = dbl半径 * Math.cos(getRadian(@dbl仰角[intIndex+1])) * Math.cos(getRadian(@dbl俯角[intIndex+1]));

			GL.Begin(GL::LINES);
			GL.Vertex3d( dblSx, dblSy, dblSz );
			GL.Vertex3d( dblEx, dblEy, dblEz );
			GL.End();

		end

	end

	def InitializePoints

		dbl距離 = 2.0;
		int方向 = 0.0;  #  0 → 360

		srand(1)

		@dbl仰角[0] = dbl距離 * Math.cos( getRadian(int方向) );
		@dbl俯角[0] = dbl距離 * Math.sin( getRadian(int方向) );

		1.upto(MAX_COUNT - 1) do |intIndex|

			int方向 = rand() * 360;

=begin
			if int方向 < 90 then
				redo
			end

			if int方向 > 270 then
				redo
			end
=end

			@dbl仰角[intIndex] = @dbl仰角[intIndex-1] + dbl距離 * Math.cos( getRadian(int方向) );
			@dbl俯角[intIndex] = @dbl俯角[intIndex-1] + dbl距離 * Math.sin( getRadian(int方向) );

		end

	end

	def idle()
		glutPostRedisplay();
	end

	def reshape(w,h)

		GL.Viewport(0,0,w,h)
	
		GL.MatrixMode(GL::GL_PROJECTION)
		GL.LoadIdentity()
		GLU.Perspective(45.0, w.to_f()/h.to_f(), 0.1, 100.0)

	end

	def display()

		GL.MatrixMode(GL::GL_MODELVIEW)
		GL.LoadIdentity()
		GLU.LookAt(0.0, 0.0, 20.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)

		GL.ClearColor(0.0, 0.0, 0.0, 1.0)
		GL.Clear(GL::GL_COLOR_BUFFER_BIT | GL::GL_DEPTH_BUFFER_BIT)

		GL.Rotate(@rotX, 1, 0, 0)
		GL.Rotate(@rotY, 0, 1, 0)

		DrawWireCube()

		DrawPointsSphere()

		GLUT.SwapBuffers()

	end

	def mouse(button,state,x,y)

		if button == GLUT::GLUT_LEFT_BUTTON && state == GLUT::GLUT_DOWN then
			@start_x = x
			@start_y = y
			@drag_flg = true
		elsif state == GLUT::GLUT_UP then
			@drag_flg = false
		end

	end

	def motion(x,y)

		if @drag_flg then

			dx = x - @start_x
			dy = y - @start_y

			@rotY += dx
			@rotY = @rotY % 360

			@rotX += dy
			@rotX = @rotX % 360

		end

		@start_x = x
		@start_y = y

		GLUT.PostRedisplay()

	end

	def keyboard(key, x, y)

		case key
			when 'r'
				InitializePoints()
			when 'q'
				exit()
		end

	end

	def initialize()

		@start_x = 0
		@start_y = 0
		@rotY = 0
		@rotX = 0
		@drag_flg = false

		GLUT.InitWindowPosition(100, 100)
		GLUT.InitWindowSize(300,300)
		GLUT.Init
		GLUT.InitDisplayMode(GLUT::GLUT_DOUBLE | GLUT::GLUT_RGB | GLUT::GLUT_DEPTH)
		GLUT.CreateWindow("Ruby de OpenGL")

		GL.Enable(GL::GL_DEPTH_TEST)
	
		GL.FrontFace(GL::GL_CW)
		GL.Enable(GL::GL_AUTO_NORMAL)
		GL.Enable(GL::GL_NORMALIZE)
		GL.Enable(GL::GL_DEPTH_TEST)
		GL.DepthFunc(GL::GL_LESS)

		@dbl仰角 = Array.new(MAX_COUNT, 0);   #  0.0  →  360.0
		@dbl俯角 = Array.new(MAX_COUNT, 0);   #  0.0  →  360.0

		InitializePoints()

		GL.ShadeModel(GL::FLAT)
	
		GLUT.IdleFunc(method(:idle).to_proc());
		GLUT.ReshapeFunc(method(:reshape).to_proc())
		GLUT.DisplayFunc(method(:display).to_proc())
		GLUT.MouseFunc(method(:mouse).to_proc())
		GLUT.MotionFunc(method(:motion).to_proc())
		GLUT.KeyboardFunc(method(:keyboard).to_proc());

	end
	
	def start()
		GLUT.MainLoop()
	end

end

ThreeDimentionAnimation.new().start()
