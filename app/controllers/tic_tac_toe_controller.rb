class TicTacToeController < ApplicationController
  def get
    channel = params['channel_id']
    userName = params['user_name']
    text = params['text']
    b = Board.new(:channel => channel)
    b.player1 = userName
    b.player2 = 'testRobot'
    b.state = '001012200'
    b.next = userName
    response = { :response_type => 'in_channel', :text => 'New game' + text, :attachments => [ b ] }
    render json: response
  end
end
