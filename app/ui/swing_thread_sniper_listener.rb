java_import javax.swing.SwingUtilities

class SwingThreadSniperListener
  def initialize(snipers)
    @snipers = snipers
  end

  def sniper_state_changed(snapshot)
    SwingUtilities.invokeLater do
      @snipers.sniper_state_changed(snapshot)
    end
  end
end
