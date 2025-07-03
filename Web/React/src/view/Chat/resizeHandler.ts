import EventEmitter from 'eventemitter3';

const resizeHandler = new EventEmitter();

window.addEventListener('resize', () => {
  resizeHandler.emit('resize');
});

export default resizeHandler;
