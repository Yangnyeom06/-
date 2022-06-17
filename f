
import pygame
import random
from pygame import *



########################################################################
# 기본 세팅


screen_width = 1600
screen_heith = 900
screen = pygame.display.set_mode((screen_width, screen_heith), 0, 32)
DISPLAY = (screen_width, screen_heith)
HALF_WIDTH = int(screen_width / 2)
HALF_HEIGHT = int(screen_heith / 2)

playing = True


pygame.display.set_caption("타워 디펜스")


#########################################################################


def startScreen():
    pygame.init()
    MOUSEBUTTONDOWN = False
    while True:
        screen.fill((0,0,0))
       

        font = pygame.font.Font(None, 100)
        Text = font.render("touch to screen",True,(0,255,0))
        screen.blit(Text,(HALF_WIDTH,HALF_HEIGHT))

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type==pygame.QUIT:
                pygame.quit()
                exit(0)
            elif event.type==pygame.MOUSEBUTTONDOWN:
                if event.type==pygame.MOUSEBUTTONDOWN:
                    MOUSEBUTTONDOWN = True 

        if MOUSEBUTTONDOWN:
            main()


def main():

    screen = pygame.display.set_mode(DISPLAY)
    clock = pygame.time.Clock()

    up = down = left = right = running = False
    bg = Surface((610, 60))
    bg.convert()
    bg.fill(Color("#FFFFFF"))
    entities = pygame.sprite.Group()
    player = Player(300, 960-32)
    platforms = []


    x = y = 0
    level = [
        "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                                                         E                 P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P               E                                                                           P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                      PPPPPPPPPPPPPPPPP                                    P",
        "P                                                                                           P",
        "P                                                           E                               P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P               E                                                                           P",
        "P         E                                                                                 P",
        "P                     E                                                                     P",
        "P                                                                                           P",
        "P              E                                                                            P",
        "P                                                                                           P",
        "P                                                                          E                P",
        "P                                                                                           P",
        "P                                                                         E                 P",
        "P                                                                                           P",
        "P                                                                                           P",
        "P                                             E                                             P",
        "P                                                                                           P",
        "P                                                                                           P",
        "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"]

    # build the level
    for row in level:
        for col in row:
            if col == "P":
                p = Platform(x, y)
                platforms.append(p)
                entities.add(p)
            if col == "E":
                enemy = Enemy(x, y)
                platforms.append(enemy)
                entities.add(enemy)

    # 32 칸 옆으로 가서 또 그린다
            x += 64
        y += 64
        x = 0

    total_level_width  = len(level[0])*64
    total_level_height = len(level)*65
    camera = Camera(complex_camera, total_level_width, total_level_height)
    entities.add(player)


    # 게임 실행 루프 (메인 루프)
    while playing: # 게임 실행

        clock.tick(60) # FPS



        for event in pygame.event.get():
                if event.type == QUIT: raise SystemExit#, "QUIT"
                if event.type == KEYDOWN and event.key == K_ESCAPE:
                    raise SystemExit#, "ESCAPE"
                if event.type == KEYDOWN and event.key == K_UP:
                    up = True
                if event.type == KEYDOWN and event.key == K_DOWN:
                    down = True
                if event.type == KEYDOWN and event.key == K_LEFT:
                    left = True
                if event.type == KEYDOWN and event.key == K_RIGHT:
                    right = True
                if event.type == KEYDOWN and event.key == K_a:
                    t = Tower(player.rect.left, player.rect.top)
                    platforms.append(t)
                    entities.add(t)

                if event.type == KEYUP and event.key == K_UP:
                    up = False
                if event.type == KEYUP and event.key == K_DOWN:
                    down = False
                if event.type == KEYUP and event.key == K_RIGHT:
                    right = False
                if event.type == KEYUP and event.key == K_LEFT:
                    left = False


        # draw background
        for y in range(60):
            for x in range(60):
                screen.blit(bg, (x * 60, y * 60))

 
        camera.update(player)

        # 플레이어 업데이트 및 다른 것도 그림
#        enemy.produce(platforms, entities)
        player.move(platforms, entities)
        player.update(up, down, left, right, platforms, entities)
        
        
        for entitie in entities:
            screen.blit(entitie.image, camera.apply(entitie))



        # 화면 업데이트
        pygame.display.update()



    # pygame 종료
    pygame.quit()




### 카메라 #######################################################################################################################################################################
class Camera(object):
    def __init__(self, camera_func, width, height):
        self.camera_func = camera_func
        self.state = Rect(0, 0, width, height)

    def apply(self, target):
        return target.rect.move(self.state.topleft)

    def update(self, target):
        self.state = self.camera_func(self.state, target.rect)

def simple_camera(camera, target_rect):
    l, t, _, _ = target_rect
    _, _, w, h = camera
    return Rect(-l+HALF_WIDTH, -t+HALF_HEIGHT, w, h)

def complex_camera(camera, target_rect):
    l, t, _, _ = target_rect
    _, _, w, h = camera
    l, t, _, _ = -l+HALF_WIDTH, -t+HALF_HEIGHT, w, h

    l = min(0, l)                           # stop scrolling at the left edge
    l = max(-(camera.width-screen_width), l)   # stop scrolling at the right edge
    t = max(-(camera.height-screen_heith), t) # stop scrolling at the bottom
    t = min(0, t)                           # stop scrolling at the top
    return Rect(l, t, w, h)
#################################################################################################################################################################################



objects = []
enemys = []
###################################################################
class BaseObject:
    def __init__(self, spr, coord, kinds, game):
        self.kinds = kinds
        self.spr = spr
        self.spr_index = 0
        self.game = game
        self.width = spr[0].get_width()
        self.height = spr[0].get_height()
        self.direction = True
        self.movement = [0, 0]
        self.collision = {'top' : False, 'bottom' : False, 'right' : False, 'left' : False}
        self.frameSpeed = 0
        self.frameTimer = 0
        self.vspeed = 0
        self.rect = pygame.rect.Rect(coord[0], coord[1], self.width, self.height)
        self.destroy = False




    def draw(self):

        if self.kinds == 'enemy' and self.hp < self.hpm:
            pygame.draw.rect(self.game.screen_scaled, (131, 133, 131)
            , [self.rect.x - 1 - self.game.camera_scroll[0], self.rect.y - 5 - self.game.camera_scroll[1], 10, 2])
            pygame.draw.rect(self.game.screen_scaled, (189, 76, 49)
            , [self.rect.x - 1 - self.game.camera_scroll[0], self.rect.y - 5 - self.game.camera_scroll[1], 10 * self.hp / self.hpm, 2])
   
    def destroy_self(self):
        if self.kinds == 'enemy':
            enemys.remove(self)
        objects.remove(self)
        del(self)
###################################################################


### 적 오브젝트 클래스 ##############################################
class EnemyObject(BaseObject):
    def __init__(self, spr, coord, kinds, game, types):
        super().__init__(spr, coord, kinds, game)
        self.types = types
        self.frameSpeed = 0
        self.frameTimer = 0
        self.actSpeed = 0
        self.actTimer = 0
        self.hpm = 0
        self.hp = 0

    def events(self):
        if self.hp < 1:
            self.destroy = True
            self.game.sound_monster.play()

        self.vspeed += 0.2

        if self.vspeed > 3:
            self.vspeed = 3

        if self.types == 'enemy1':       # enemy1일 경우
            if self.frameTimer >= self.frameSpeed:
                self.frameTimer = 0
                if self.spr_index < len(self.spr) - 1:
                    self.spr_index += 1
                else:
                    self.spr_index = 0
###################################################################



class Entity(pygame.sprite.Sprite):
    def __init__(self):
        pygame.sprite.Sprite.__init__(self)




### 플레이어 클래스 ##############################################################################################################################################################
class Player(Entity):
    def __init__(self, x, y):
        Entity.__init__(self)

        self.xvel = 0
        self.yvel = 0
        self.image = Surface((32,32))
        self.image.fill(Color("#0000FF"))
        self.image.convert()
        self.hp = 500
        self.damage = 10
        # 플레이어 충돌 크기 부분
        self.rect = Rect(x, y, 32, 32)

    def update(self, up, down, left, right, platforms, entities):
        if up:
            self.yvel = -100
        if down:
            self.yvel = 100
        if left:
            self.xvel = -100
        if right:
            self.xvel = 100
            
        if not(left or right):
            self.xvel = 0
        
        if not(up or down):
            self.yvel = 0
            
        self.rect.left += self.xvel
        self.collide(self.xvel, 0, platforms, entities)

        self.rect.top += self.yvel
        self.collide(0, self.yvel, platforms, entities)


    ### 충돌처리 부분 ###
    def collide(self, xvel, yvel, platforms, entities):
        for enemy in platforms:
            if pygame.sprite.collide_rect(self, enemy):
                if isinstance(enemy, Enemy):
                    #self.hp -= p.damage
                    enemy.hp -= self.damage
                    print(self.hp)
                    print(enemy.hp)

                if xvel > 0:
                    self.rect.right = enemy.rect.left

                if xvel < 0:
                    self.rect.left = enemy.rect.right

                if yvel > 0:
                    self.rect.bottom = enemy.rect.top

                if yvel < 0:
                    self.rect.top = enemy.rect.bottom

                if enemy.hp <= 0:
                    platforms.remove(enemy)
                    entities.remove(enemy)
                    del(enemy)


                if self.hp <= 0:
                    pygame.event.post(pygame.event.Event(QUIT))

    def move(self, platforms, entities):
        for enemy in platforms:
            #print(enemy)
            if not pygame.sprite.collide_rect(self, enemy):
                if isinstance(enemy, Enemy):
                    #print(enemy)
                    if self.rect.right < enemy.rect.right:
                        enemy.xvel -= 1 - (abs(self.rect.right) - abs(enemy.rect.right)) / 70

                    if self.rect.left > enemy.rect.left:
                        enemy.xvel += 1 + (abs(self.rect.left) - abs(enemy.rect.left)) / 70

                    if self.rect.top < enemy.rect.top:
                        enemy.yvel -= 1 - (abs(self.rect.top) - abs(enemy.rect.top)) / 70

                    if self.rect.bottom > enemy.rect.bottom:
                        enemy.yvel += 1 + (abs(self.rect.bottom) - abs(enemy.rect.bottom)) / 70

                    enemy.rect.left += enemy.xvel
                    
                    enemy.rect.top += enemy.yvel

            if pygame.sprite.collide_rect(self, enemy):
                if isinstance(enemy, Enemy):
                    if enemy.rect.right == enemy.rect.right:
                        enemy.xvel = 0

                    if enemy.rect.left == enemy.rect.left:
                        enemy.xvel = 0

                    if enemy.rect.top == enemy.rect.top:
                        enemy.yvel = 0

                    if enemy.rect.bottom == enemy.rect.bottom:
                        enemy.yvel = 0



            enemy.xvel = 0
            enemy.yvel = 0

####################################################################################



'''
def move(self, platforms):

    for enemy in platforms:
        if not pygame.sprite.collide_rect(self, enemy):
            if isinstance(enemy, Enemy):
                if self.rect.right < enemy.rect.right:
                    enemy.xvel += 2

                if self.rect.left > enemy.rect.left:
                    enemy.xvel -= 2

                if self.rect.top < enemy.rect.top:
                    enemy.yvel += 2

                if self.rect.bottom > enemy.rect.bottom:
                    enemy.yvel -= 2

                enemy.rect.left += enemy.xvel

                enemy.rect.top += enemy.yvel

        enemy.xvel = 0
        enemy.yvel = 0
'''


class Platform(Entity):
    def __init__(self, x, y):
        Entity.__init__(self)
        self.image = Surface((60, 119))
        self.image.convert()
        self.image.fill(Color("#f20201"))
        self.rect = Rect(x, y, 60, 119)
        self.hp = 1
        self.damage = 0

    def dot_floor_tile(self):
        self.image = Surface((60, 60))
        self.image.convert()
        self.image.fill(Color("#210A1F"))


    def update(self):
        pass


class Enemy(Entity):
    def __init__(self, x, y):
        Entity.__init__(self)
        self.image = Surface((32,32))
        self.image.fill(Color("#f41000"))
        self.hp = 1000
        self.damage = 5
        self.xvel = 0
        self.yvel = 0
        self.rect = Rect(x, y, 32, 32)

    def collide2(self, platforms):
        for  enemy in platforms:
            if pygame.sprite.collide_rect(self, enemy):
                if isinstance(enemy, Enemy):
                    if enemy.rect.right == enemy.rect.right:
                        enemy.xvel = 0

                    if enemy.rect.left == enemy.rect.left:
                        enemy.xvel = 0

                    if enemy.rect.top == enemy.rect.top:
                        enemy.yvel = 0

                    if enemy.rect.bottom == enemy.rect.bottom:
                        enemy.yvel = 0


        

class Tower(Platform):
    def __init__(self, x, y):
        Platform.__init__(self, x, y)
        self.image.fill(Color("#A1DF54"))



if __name__ == "__main__":
    startScreen()
