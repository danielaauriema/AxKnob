{ ********************************************************************** }
{  AxKnob                                                                }
{                                                                        }
{  This program is free software: you can redistribute it and/or modify  }
{  it under the terms of the GNU General Public License as published by  }
{  the Free Software Foundation, either version 3 of the License, or     }
{  any later version.                                                    }
{                                                                        }
{  This program is distributed in the hope that it will be useful,       }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of        }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          }
{   GNU General Public License for more details. (www.gnu.org)           }
{                                                                        }
{  2019-08-08 Daniela Auriema                                            }
{ ********************************************************************** }
unit AxKnob;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Forms;

type

  TAxKnob = class (TCustomControl)
  private
    FClick: Boolean;
    FPos: Integer;
    FValue: Integer;
    FInit: Integer;
    FMaxValue: Integer;
    FMinValue: Integer;
    FStep: Integer;
    FScroolStep: Integer;
    procedure SetMaxValue(const Value: Integer);
    procedure SetMinValue(const Value: Integer);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure SetValue (const Value: Integer);
  public
    constructor Create (Aowner: TComponent); override;
  published
    property MaxValue: Integer read FMaxValue write SetMaxValue;
    property MinValue: Integer read FMinValue write SetMinValue;
    property Step: Integer read FStep write FStep;
    property ScroolStep: Integer read FScroolStep write FScroolStep;
    property CurrentValue: Integer read FValue write SetValue;
  end;

procedure Register;

implementation
uses Math;

{ TAxKnob }

constructor TAxKnob.Create(Aowner: TComponent);
begin
  inherited;
  AutoSize:= False;
  Width:= 50;
  Height:= 50;
  Caption:= IntToStr (FValue);
  FMaxValue:= +100;
  FMinValue:= -100;
  FStep:= 2;
  FScroolStep:= 5;
end;

function TAxKnob.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  if WheelDelta > 0 then
    SetValue (FValue + FScroolStep)
  else if WheelDelta < 0 then
    SetValue (FValue - FScroolStep);
  Result:= inherited;
end;

procedure TAxKnob.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FPos:= Y;
  FClick:= True;
  FInit:= FValue;
end;

procedure TAxKnob.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FClick then
    SetValue (FInit - (Y - FPos) * FStep);
end;

procedure TAxKnob.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FClick:= False;
end;

procedure TAxKnob.Paint;
var
  x, y: Integer;
  w, h: Integer;
  dialH, dialW: Integer;
  zValue: Integer;
const
  dialRadius = 4;
  offset = 5;
begin
  Canvas.Brush.Style:= bsClear;
  Canvas.FillRect(ClientRect);

  w:= Canvas.TextWidth(Caption);
  h:= Canvas.TextHeight(Caption);

  Canvas.Pen.Color:= clBlack;
  Canvas.Pen.Width:= 1;
  Canvas.Ellipse(ClientRect);

  Canvas.Brush.Style:=  bsSolid;
  Canvas.Brush.Color:= clRed;

  dialW:= ClientWidth div 2 - offset;
  dialH:= ClientHeight div 2 - offset;

  zValue:= Round (270 / (MaxValue - MinValue) * (FValue - MinValue)) + 45;

  x:= Round (sin(degToRad(-zValue)) * dialW + dialW) + offset;
  y:= Round (cos(degToRad(-zValue)) * dialW + dialW) + offset;

  Canvas.Ellipse(x - dialRadius, y - dialRadius,
    x + dialRadius, y + dialRadius);

  Canvas.Brush.Style:= bsClear;
  Canvas.TextOut((ClientWidth - w)div 2, (ClientHeight - h)div 2,  Caption);
end;

procedure TAxKnob.Resize;
begin
  inherited;
  Invalidate;
end;

procedure TAxKnob.SetMaxValue(const Value: Integer);
begin
  if Value <= FMinValue then
    FMaxValue:= FMinValue + 1
  else
    FMaxValue := Value;
  if FValue > FMaxvalue then
    FValue:= FMaxValue;
  Invalidate;
end;

procedure TAxKnob.SetMinValue(const Value: Integer);
begin
  if Value >= FMaxValue then
    FMinValue:= FMaxValue - 1
  else
    FMinValue := Value;
  if FValue < FMinValue then
    FValue:= FMinValue;
  Invalidate;
end;

procedure TAxKnob.SetValue(const Value: Integer);
begin
  if Value > FMaxValue then
    FValue:= FMaxValue
  else if Value < FMinValue then
    FValue:= MinValue
  else
    FValue:= Value;
  Caption:= IntToStr(FValue);
  Invalidate;
end;

procedure Register;
begin
  RegisterComponents('AxLibrary', [TAxKnob]);
end;

end.
