class TicTacToeController < ApplicationController
  def get
    b = Board.new(:channel => 'abc')
    b.player1 = 'kaiyi'
    b.player2 = 'testRobot'
    b.state = '001012200'
    b.next = 'kaiyi'
    response = { :response_type => 'in_channel', :text => 'New game', :attachments => [ b ] }
    render json: response
  end
end
