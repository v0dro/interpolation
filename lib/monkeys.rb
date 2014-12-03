class Matrix
  def each_column(&block)
    self.column_vectors.each(&block)
  end  
end