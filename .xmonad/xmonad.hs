import XMonad

import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves
import XMonad.Actions.SinkAll

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.XPropManage

import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ToggleLayouts
{- import XMonad.Layout.ThreeColumns -}

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Window

import XMonad.Util.Run (spawnPipe)
import XMonad.Util.WindowProperties

import Control.Monad (forM_, when, unless)
import Data.List
import System.Exit
import System.IO (hPutStrLn)
import System.Environment (getEnv)

import qualified XMonad.StackSet as W
import qualified XMonad.Operations as O
import qualified Data.Map as M


main = do
    workspaceBar <- spawnPipe Main.myWorkspaceBar
    xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
        { terminal    = myTerminal
        , borderWidth = 2
        , normalBorderColor = "#222222"
        , focusedBorderColor = "deeppink"
        , modMask     = mod1Mask
        , workspaces  = [head wsname]
        , keys        = keybind
        , layoutHook  = myLayoutHook
        , logHook     = myLogHook workspaceBar
        , manageHook  = manageDocks <+> (xPropManageHook xPropMatches)
        , startupHook = myStartupHook
        }


home = "/home/naoina"
myTerminal = "lilyterm -e $HOME/bin/tmux.sh"
myTerminalClass = "Lilyterm"
barFgColor = "#999"
barBgColor = "#000"
myWorkspaceBar = "dzen2 -expand right -h 23 -y -1 -fg '" ++ barFgColor ++ "' -bg '" ++ barBgColor ++ "'"
wsname = [show n | n <- [1..9]]
autostartApps = ["xcompmgr"]

myStartupHook = do
    setWMName "LG3D"
    mapM_ spawn autostartApps


myLogHook h = do
    fadeRatioLogHook 0xffffffff 0xeeeeeeee
    dynamicLogWithPP $ workspacePP h


workspacePP h = defaultPP
    { ppCurrent = \x -> bracketColor "[" ++ x ++ bracketColor "]"
    , ppVisible = dzenColor "" ""
    , ppHidden = pad
    , ppHiddenNoWindows = pad -- ToDo change color
    , ppSep = "|"
    , ppWsSep = ""
    , ppTitle = \_ -> ""
    , ppLayout = dzenIcon
    , ppOutput = hPutStrLn h
    }
        where
          bracketColor = dzenColor barFgColor barBgColor
          dzenIcon s = case s of
                           "Mirror Tall"   -> icon "tall.xbm"
                           "ReflectX Grid" -> icon "grid.xbm"
                           otherwise       -> " " ++ s ++ " "
              where
                  icon f = " ^i(" ++ home ++ "/.dzen2/" ++ f ++ ") "


myLayoutHook = avoidStruts
             $ smartBorders
             $ onWorkspace (wsname !! 1) (reflectHoriz Grid ||| reflectHoriz tiled ||| reflectVert (Mirror tiled)) $ Mirror tiled ||| reflectHoriz tiled ||| Full
             {- ThreeCol 1 (3/100) (1/2) -}
    where
      tiled = Tall nmaster delta ratio
      nmaster = 1
      delta   = 0.03
      ratio   = 0.5


xPropMatches :: [XPropMatch]
xPropMatches =
    [([(wM_NAME, any floatApps)], pmX O.float)]
    ++
    {- [([(wM_CLASS, any ("Navigator" ==))], exShift $ wsname !! 1)] -}
    {- ++ -}
    [([(wM_CLASS, any (\s -> any (s ==) ["Chromium", "Google-chrome"]))], exShift $ wsname !! 1)]
    ++
    [([(wM_CLASS, any ("Gtk-gnutella" ==))], exShift $ wsname !! 2)]
    ++
    [([(wM_CLASS, any ("Skype" ==))], exShift $ wsname !! 8)]
        where
          floatApps name = all (\f -> f name) (determines)
          determines = [not . (myTerminalClass `isSuffixOf`)]
                       ++
                       [not . (browser `isSuffixOf`) | browser <- ["Firefox", "Gran Paradiso", "Shiretoko"]]
                       ++
                       [not . ("gtk-gnutella" `isPrefixOf`)]


exShift :: String -> Window -> X (WindowSet -> WindowSet)
exShift tag w =
    withWindowSet $ \ws -> unless (W.tagMember tag ws) (addHiddenWorkspace tag) >>
    (return $ W.shift tag)


keybind conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((controlMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask, xK_p), shellPrompt promptXPConfig)
    , ((modMask, xK_Tab), windowPromptGoto promptXPConfig)
    , ((modMask, xK_j), windows W.focusUp)
    , ((modMask, xK_k), windows W.focusDown)
    {- , ((modMask, xK_h), focusDownSelect) -}
    {- , ((modMask, xK_t), focusUpSelect) -}
    , ((modMask .|. shiftMask, xK_j), rotSlavesDown)
    , ((modMask .|. shiftMask, xK_k), rotSlavesUp)
    , ((modMask, xK_Return), promote)
    , ((modMask, xK_space), sinkAll)
    , ((modMask, xK_n), sendMessage NextLayout)
    {- , ((modMask, xK_n), sendMessage ToggleLayout) -}
    {- , ((modMask, xK_r), sendMessage NextLayout) -}
    , ((modMask .|. shiftMask, xK_c), kill)
    , ((modMask .|. shiftMask, xK_r),
        broadcastMessage ReleaseResources >> restart "xmonad" True)
    , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
    , ((controlMask .|. shiftMask, xK_j), spawn "exec kasumi")
    , ((0, xK_Print), spawn "scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/media/image/screenshot/'")
    ]
    ++
    [ ((modMask .|. m, k), f $ wsname !! n)
        | (k, n) <- zip [xK_1..xK_9] [0..8]
        , (m, f) <- [(0, gcWorkspaceView), (shiftMask, gcWorkspaceShift)]
    ]
        where
          focusDownSelect = dynamicLogString layoutPP >>= selectDown
              where
                selectDown "ReflectX Tall" = windows W.focusDown
                selectDown "Mirror Tall" = windows W.focusUp

          focusUpSelect = dynamicLogString layoutPP >>= selectUp
              where
                selectUp "ReflectX Tall" = windows W.focusUp
                selectUp "Mirror Tall" = windows W.focusDown

          layoutPP = defaultPP
            { ppCurrent = f
            , ppVisible = f
            , ppHidden = f
            , ppHiddenNoWindows = f
            , ppSep = ""
            , ppWsSep = ""
            , ppTitle = f
            , ppLayout = \t -> t
            }
          f _ = ""


gcWorkspace' dynWS f tag =
    withWindowSet $ \w ->
        dynWS tag (not $ isDupWS w) (W.workspace $ W.current w) >>
        (windows $ f $ tag)
            where
              isDupWS w = W.tagMember tag w


gcWorkspaceView :: String -> X ()
gcWorkspaceView = gcWorkspace' dynWS W.greedyView
    where
      dynWS tag nodup (W.Workspace t _ Nothing) = do
            when (tag /= t) removeWorkspace
            when nodup $ addWorkspace tag
      dynWS tag nodup _ | nodup = addWorkspace tag
      dynWS tag _ _ = windows $ W.greedyView $ tag


gcWorkspaceShift :: String -> X ()
gcWorkspaceShift = gcWorkspace' dynWS W.shift
    where
      dynWS _ _ (W.Workspace t _ Nothing) = return ()
      dynWS tag nodup _ | nodup = addHiddenWorkspace tag
      dynWS _ _ _ = return ()


promptXPConfig = defaultXPConfig
    { -- font = "xft:M+2VM+IPAG circle:size=11:antialias=true"
      bgColor = "black"
    , fgColor = "deeppink"
    , fgHLight = "gold"
    , bgHLight = "black"
    , borderColor = "gray"
    , promptBorderWidth = 2
    , position = Bottom
    , height = 25
    , historySize = 256
    }


fadeRatioLogHook :: Integer -> Integer -> X ()
fadeRatioLogHook inamt outamt = withWindowSet $ \s ->
    forM_ (concatMap visibleWins $ W.current s : W.visible s) (fadeRatio outamt) >>
    withFocused (fadeRatio inamt)
        where
          visibleWins = maybe [] unfocused . W.stack . W.workspace
          unfocused (W.Stack _ l r) = l ++ r

          fadeRatio :: Integer -> Window -> X ()
          fadeRatio amt = flip setOpacity amt
              where
                setOpacity :: Window -> Integer -> X ()
                setOpacity w t = withDisplay $ \dpy -> do
                    a <- getAtom "_NET_WM_WINDOW_OPACITY"
                    c <- getAtom "CARDINAL"
                    whenX (hasProperty (ClassName myTerminalClass) w) $
                      io $ changeProperty32 dpy w a c propModeReplace [fromIntegral t]
