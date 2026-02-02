fetch('updates.json')
  .then(res => res.json())
  .then(data => {
    data.updates.forEach(update => {
      // render row
    });
  });
